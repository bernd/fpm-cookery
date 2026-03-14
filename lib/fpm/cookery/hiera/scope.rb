require 'fpm/cookery/facts'

module FPM
  module Cookery
    module Hiera
      class ScopeError < StandardError; end

      # Wraps a recipe class, adding a +[]+ method so that it can be used as a
      # +Hiera+ scope.
      #
      # NOTE: Facter fallback was removed. Only recipe methods and
      # FPM::Cookery::Facts methods are available for Hiera interpolation.
      # Facter-specific facts like +processorcount+ or +ipaddress+ are no
      # longer resolvable via +%{scope("key")}+.
      class Scope
        attr_reader :recipe

        def initialize(recipe)
          @recipe = recipe
        end

        # Allow Hiera to perform +%{scope("key")}+ interpolations using data
        # from the recipe class and +FPM::Cookery::Facts+.  Expects +name+ to
        # be a method name.  Raises +ScopeError+ if the key cannot be resolved
        # (e.g. via direct calls).  In normal Hiera flow, +include?+ gates
        # access so unresolvable keys are treated as empty strings by Hiera.
        def [](name)
          [recipe, FPM::Cookery::Facts].each do |source|
            if source.respond_to?(name)
              return source.send(name)
            end
          end

          raise ScopeError, "Unknown Hiera scope key '#{name}'. " \
            "The Facter fallback has been removed. Only recipe methods and " \
            "FPM::Cookery::Facts methods are available for interpolation."
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
