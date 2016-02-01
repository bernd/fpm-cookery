require 'singleton'

module FPM
  module Cookery
    class Book
      include Singleton

      attr_reader :config

      def initialize
        @recipe = nil
      end

      # Load the given file and instantiate an object. Wrap the class in an
      # anonymous module to avoid namespace cluttering. (see Kernel.load)
      def load_recipe(filename, config, &callback)
        @config = config

        Kernel.load(filename, true)
        callback.call(@recipe.new(filename, config))
      end

      def add_recipe_class(klass)
        @recipe = klass
      end

      def inject_config!(klass)
        # Hijack the BaseRecipe singleton to make the +config+ object
        # available when the BaseRecipe subclass is loaded.
        config = self.config
        (class << klass ; self ; end).send(:define_method, :config) do
          config
        end
      end
    end
  end
end
