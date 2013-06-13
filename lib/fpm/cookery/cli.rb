require 'fpm/cookery/book_hook'
require 'fpm/cookery/recipe'
require 'fpm/cookery/facts'
require 'fpm/cookery/packager'
require 'fpm/cookery/omnibus_packager'
require 'fpm/cookery/log'
require 'fpm/cookery/log/output/console'
require 'fpm/cookery/log/output/console_color'
require 'optparse'

module FPM
  module Cookery
    class CLI
      def initialize
        @colors = true
        @debug = false
      end

      def args(argv)
        program = File.basename($0)
        options = OptionParser.new
        options.banner = \
          "Usage: #{program} [options] [path/to/recipe.rb] action [...]"
        options.separator "Actions:"
        options.separator "  package        - builds the package"
        options.separator "  clean          - cleans up"
        options.separator "  install-deps   - installs build and runtime dependencies"
        options.separator "Options:"

        options.on("-c", "--color",
                   "Toggle color. (default #{@colors.inspect})") do |o|
          @colors = !@colors
        end

        options.on("-D", "--debug", "Enable debug output.") do |o|
          @debug = true
        end

        options.on("-t TARGET", "--target TARGET",
                  "Set the desired fpm output target (deb, rpm, etc)") do |o|
          @target = o
        end

        options.on("-p PLATFORM", "--platform PLATFORM",
                  "Set the target platform. (centos, ubuntu, debian)") do |o|
          @platform = o
        end

        options.on("-V", "--version", "Show fpm-cookery and fpm version") do
          require 'fpm/version'
          require 'fpm/cookery/version'

          puts "fpm-cookery v#{FPM::Cookery::VERSION} (fpm v#{FPM::VERSION})"
          exit 0
        end

        options.on("--no-deps", "Disable dependency checking") do |o|
          @nodep = true
        end

        # Parse flags and such, remainder is all non-option args.
        remainder = options.parse(argv)

        # Initialize logging.
        FPM::Cookery::Log.enable_debug(@debug)
        if @colors
          FPM::Cookery::Log.output(FPM::Cookery::Log::Output::ConsoleColor.new)
        else
          FPM::Cookery::Log.output(FPM::Cookery::Log::Output::Console.new)
        end

        # Default recipe to find is in current directory named 'recipe.rb'
        @filename = File.expand_path('recipe.rb')

        # See if something that looks like a recipe path is in arguments
        remainder.each do |arg|
          # If 'foo.rb' was given, and it exists, use it.
          if arg =~ /\.rb$/ and File.exists?(arg)
            remainder.delete(arg)
            @filename = arg
            break
          end

          # Allow giving the directory containing a recipe.rb
          if File.directory?(arg) and File.exists?(File.join(arg, "recipe.rb"))
            remainder.delete(arg)
            @filename = File.join(arg, "recipe.rb")
            break
          end
        end

        # Everything that's not the recipe filename is an action.
        @actions = remainder
        return self
      end

      def validate
        unless File.exists?(@filename)
          Log.error 'No recipe.rb found in the current directory, abort.'
          exit 1
        end

        # Default action is "package"
        if @actions.empty?
          @actions = ["package"]
        end

        # Override the detected platform.
        if @platform
          FPM::Cookery::Facts.platform = @platform
        end

        if @target
          FPM::Cookery::Facts.target = @target
        end

        if FPM::Cookery::Facts.target.nil?
          Log.error "No target given and we're unable to detect your platform"
          exit 1
        end

      end

      def run
        validate

        FPM::Cookery::Recipe.send(:include, FPM::Cookery::BookHook)

        FPM::Cookery::Book.instance.load_recipe(@filename) do |recipe|
          packager = FPM::Cookery::Packager.new(recipe, :dependency_check => !@nodep)
          packager.target = FPM::Cookery::Facts.target.to_s

          @actions.each do |action|
            case action
            when "clean" ; packager.cleanup
            when "package"
              if recipe.omnibus_package == true
                FPM::Cookery::OmnibusPackager.new(packager).run
              else
                packager.dispense
              end
            when "install-deps" ; packager.install_deps
            else
              # TODO(sissel): fail if this happens
              Log.error "Unknown action: #{action}"
            end
          end
        end
      end
    end
  end
end
