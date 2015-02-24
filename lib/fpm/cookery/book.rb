require 'singleton'

module FPM
  module Cookery
    class Book
      include Singleton

      def initialize
        @recipe = nil
      end

      # Load the given file and instantiate an object. Wrap the class in an
      # anonymous module to avoid namespace cluttering. (see Kernel.load)
      def load_recipe(filename, config, recipe_config, &callback)
        Kernel.load(filename, true)
        callback.call(@recipe.new(filename, config, recipe_config))
      end

      def add_recipe_class(klass)
        @recipe = klass
      end
    end
  end
end
