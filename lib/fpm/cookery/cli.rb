require 'fpm/cookery/book_hook'
require 'fpm/cookery/recipe'
require 'fpm/cookery/packager'

module FPM
  module Cookery
    class CLI
      def initialize(argv)
        @argv = argv
      end

      def run
        filename = @argv.find {|arg| arg =~ /\.rb$/ and File.exists?(arg) }
        filename ||= File.expand_path('recipe.rb')

        unless File.exists?(filename)
          STDERR.puts 'No recipe.rb found in the current directory, abort.'
          exit 1
        end

        FPM::Cookery::Recipe.send(:include, FPM::Cookery::BookHook)

        FPM::Cookery::Book.load_recipe(filename) do |recipe|
          packager = FPM::Cookery::Packager.new(recipe)

          if @argv.include?('clean')
            packager.cleanup
          else
            packager.dispense
          end
        end
      end
    end
  end
end
