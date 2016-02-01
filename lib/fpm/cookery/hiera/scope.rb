require 'facter'
require 'fpm/cookery/facts'

module FPM
  module Cookery
    module Hiera
      # Wraps an FPM::Cookery::Recipe object, adding a '[]' so
      # that it can be used as a Hiera scope.
      class Scope
        attr_reader :recipe

        def initialize(recipe)
          @recipe = recipe
        end

        # Allow Hiera to perform +%{scope("key")}+ interpolations using data
        # from the {Recipe} object, its metaclass, and +Facter+
        # @param [String, Symbol] name  a method name or Facter fact name
        # @return [Object] the result of the lookup.  Will be +nil+ if lookup
        #   failed to fetch a result.
        def [](name)
          # Try to retrieve data from the recipe and FPM::Cookery's facts
          [recipe, recipe.class, FPM::Cookery::Facts].each do |source|
            if source.respond_to?(name)
              return source.send(name)
            end
          end

          # As a final option, try to retrieve it from Facter
          unless (result = Facter[name]).nil?
            result.value
          end
        end
      end
    end
  end
end
