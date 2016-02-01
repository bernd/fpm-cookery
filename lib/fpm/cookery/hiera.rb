require 'hiera'
require 'fpm/cookery/hiera/defaults'
require 'fpm/cookery/hiera/scope'
require 'fpm/cookery/log/hiera'

module FPM
  module Cookery
    # Implement Hiera lookups and interpolation for {Recipe}s
    module Hiera
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods

          def datadir
            self.class.datadir
          end

          extend Forwardable
          def_delegators klass, :hiera, :lookup, :apply
        end
      end

      module ClassMethods
        def datadir
          raise NoMethodError, "you must define ##{__method__}"
        end

        def hiera
          @hiera ||= FPM::Cookery::Hiera::Instance.new(self)
        end

        extend SingleForwardable
        def_delegators :hiera, :lookup, :apply
      end

      # +Hiera+ subclass that wraps a {Recipe}
      class Instance < ::Hiera
        include FPM::Cookery::Hiera::Defaults

        attr_reader :recipe_klass, :recipe, :scope

        def initialize(recipe_klass, options = {})
          @recipe_klass = recipe_klass
          @scope = Scope.new(recipe_klass)

          # For some reason, Hiera expects a hash with just one key
          # (:config).
          super({:config => hiera_config(options)})
        end

        # Just provides a default scope @note In order for %{hiera("...")}
        # lookups to function properly, we have to do the +lookup(sym, ...) ||
        # lookup(sym.to_s, ...)+ logic here: when Hiera calls Backend.lookup,
        # this method will try both keys.
        def lookup(key, default = nil, scope = self.scope, *rest)
          super(key.to_sym, default, scope, *rest) || super(key.to_s, default, scope, *rest)
        end
        alias_method :[], :lookup

        def apply
          _apply = lambda do |m, l|
            if (result = lookup(m)).nil?
              FPM::Cookery::Log.warn("No result for `#{m}'")
              return
            end

            FPM::Cookery::Log.warn("Setting `#{m}' to #{result}")
            l.call(m, result)
          end

          apply_attr = lambda { |m, result| recipe_klass.send(m, result) }
          apply_list_attr = lambda { |m, result| recipe_klass.send(m, *result) }
          apply_hash_attr = lambda { |m, result| recipe_klass.send(m).merge! result }

          recipe_klass.rw_attrs.each { |m| _apply.call(m, apply_attr) }
          recipe_klass.rw_list_attrs.each { |m| _apply.call(m, apply_list_attr) }
          recipe_klass.rw_hash_attrs.each { |m| _apply.call(m, apply_hash_attr) }
        end
      end
    end
  end
end
