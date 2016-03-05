require 'hiera'
require 'fpm/cookery/hiera/defaults'
require 'fpm/cookery/hiera/scope'
require 'fpm/cookery/log/hiera'

module FPM
  module Cookery
    # Implement Hiera lookups and interpolation for recipes
    module Hiera
      # +Hiera+ subclass that wraps a recipe class
      class Instance < ::Hiera
        include FPM::Cookery::Hiera::Defaults

        attr_reader :recipe, :scope

        # Expects a recipe class and a hash containing one key, +:config+.
        def initialize(recipe, options = {})
          @recipe = recipe
          @scope = Scope.new(recipe)

          # For some reason, +Hiera+'s constructor expects a hash with just the
          # one key.
          super({ :config => hiera_config(options) })
        end

        # Provides a default scope, and attempts to look up the key both as a
        # string and as a symbol.
        def lookup(key, default = nil, scope = self.scope, *rest)
          super(key.to_sym, default, scope, *rest) || super(key.to_s, default, scope, *rest)
        end
        alias_method :[], :lookup
      end
    end
  end
end
