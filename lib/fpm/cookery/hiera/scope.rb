require 'fpm/cookery/facts'

module FPM
  module Cookery
    module Hiera
      # Wraps a recipe class, adding a +[]+ method so that it can be used as a
      # +Hiera+ scope.
      class Scope
        attr_reader :recipe

        def initialize(recipe)
          @recipe = recipe
        end

        # Allow Hiera to perform +%{scope("key")}+ interpolations using data
        # from the recipe class and +FPM::Cookery::Facts+.  Expects +name+ to
        # be a method name.  Returns the result of the lookup.  Will be +nil+
        # if lookup failed to fetch a result.
        def [](name)
          [recipe, FPM::Cookery::Facts].each do |source|
            if source.respond_to?(name)
              return source.send(name)
            end
          end

          nil
        end

        # Newer versions of Hiera requires also +#include?+ method for context
        def include?(name)
          [recipe, FPM::Cookery::Facts].each do |source|
            return true if source.respond_to?(name)
          end

          false
        end
      end
    end
  end
end
