require 'fpm/cookery/book'

module FPM
  module Cookery
    module BookHook
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def inherited(klass)
          FPM::Cookery::Book.instance.add_recipe_class(klass)
          FPM::Cookery::Book.instance.inject_class_methods!(klass)
        end
      end
    end
  end
end
