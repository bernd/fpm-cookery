require 'singleton'
require 'fpm/cookery/path'

module FPM
  module Cookery
    class Book
      include Singleton

      attr_accessor :filename, :config

      def initialize
        @recipe = nil
      end

      # Load the given file and instantiate an object. Wrap the class in an
      # anonymous module to avoid namespace cluttering. (see Kernel.load)
      def load_recipe(filename, config, &callback)
        @filename = FPM::Cookery::Path.new(filename).realpath
        @config = config

        Kernel.load(@filename.to_path, true)
        callback.call(@recipe.new)
      end

      def add_recipe_class(klass)
        @recipe = klass
      end

      # Hijack the recipe singleton to make the +filename+ and +config+ objects
      # available when a descendent of BaseRecipe is declared.  This makes it
      # possible to do Hiera lookups at class definition time.
      def inject_class_methods!(klass)
        # It's necessary to close over local variables because the receiver
        # changes within the scope of +define_method+, so +self.filename+ would
        # wrongly refer to +singleton_klass.filename+.
        filename = self.filename
        config = self.config

        singleton_klass = (class << klass ; self ; end)

        singleton_klass.send(:define_method, :filename) do
          filename
        end

        singleton_klass.send(:define_method, :config) do
          config
        end
      end
    end
  end
end
