require 'fpm/cookery/book'

module FPM
  module Cookery
    module BookHook
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def inherited(klass)
          FPM::Cookery::Book.loaded_recipe(klass)
        end
      end
    end
  end
end
