module FPM
  module Cookery
    class Book
      # Load the given file. Wrap the class in an anonymous module to
      # avoid namespace cluttering. (see Kernel.load)
      def self.load(filename, &callback)
        Kernel.load(filename, true)
        callback.call(@recipe)
      end

      def self.loaded_recipe(klass)
        @recipe = klass
      end
    end
  end
end
