module FPM
  module Cookery
    class Book
      # Load the given file and instantiate an object. Wrap the class in an
      # anonymous module to avoid namespace cluttering. (see Kernel.load)
      def self.load_recipe(filename, &callback)
        Kernel.load(filename, true)
        callback.call(@recipe.new(filename))
      end

      def self.loaded_recipe(klass)
        @recipe = klass
      end
    end
  end
end
