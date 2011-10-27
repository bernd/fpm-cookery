require 'fpm/cookery/book_hook'
require 'fpm/cookery/recipe'
require 'fpm/cookery/packager'
require 'optparse'

module FPM
  module Cookery
    class CLI
      def args(argv)
        program = File.basename($0)
        options = OptionParser.new
        options.banner = \
          "Usage: #{program} [options] [path/to/recipe.rb] action [...]"
        options.separator "Actions:"
        options.separator "  package - builds the package"
        options.separator "  clean - cleans up"
        options.separator "Options:"

        options.on("-t TARGET", "--target TARGET",
                  "Set the desired fpm output target (deb, rpm, etc)") do |o|
          @target = o
        end

        options.on("-p PLATFORM", "--platform PLATFORM",
                  "Set the target platform. (centos, ubuntu, debian)") do |o|
          @platform = o
        end

        # Parse flags and such, remainder is all non-option args.
        remainder = options.parse(argv)

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
          STDERR.puts 'No recipe.rb found in the current directory, abort.'
          exit 1
        end

        if @target.nil?
          # TODO(sissel): Detect platform, try to guess @target?
          @target = "deb"
          puts "No --target given, assuming #{@target}"
        end

        # Default action is "package"
        if @actions.empty?
          @actions = ["package"]
          puts "No actions given, assuming 'package'"
        end

        # Override the detected platform.
        if @platform
          FPM::Cookery::Facts.platform = @platform
        end
        puts "Platform: #{FPM::Cookery::Facts.platform}"
      end

      def run
        validate

        FPM::Cookery::Recipe.send(:include, FPM::Cookery::BookHook)

        FPM::Cookery::Book.load_recipe(@filename) do |recipe|
          packager = FPM::Cookery::Packager.new(recipe)
          packager.target = @target

          @actions.each do |action|
            case action
            when "clean" ; packager.cleanup
            when "package" ; packager.dispense
            else
              # TODO(sissel): fail if this happens
              puts "Unknown action: #{action}"
            end
          end
        end
      end
    end
  end
end
