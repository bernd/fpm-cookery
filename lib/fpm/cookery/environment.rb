require 'fpm/cookery/log'

module FPM
  module Cookery
    class Environment < Hash
      REMOVALS = %w(
        BUNDLE_GEMFILE RUBYOPT BUNDLE_BIN_PATH GEM_HOME GEM_PATH
      ).freeze

      # Coerce keys and values to +String+s on creation
      def self.[](h = {})
        super(Hash[h.map { |k, v| [k.to_s, v.to_s] }])
      end

      def [](key)
        super(key.to_s)
      end

      def []=(key, value)
        if value.nil?
          delete(key.to_s)
        else
          super(key.to_s, value.to_s)
        end
      end

      def merge(other)
        super(self.class[other])
      end

      def merge!(other)
        super(self.class[other])
      end

      def with_clean
        saved_env = ENV.to_hash

        REMOVALS.each do |var|
          value = ENV.delete(var)
          Log.debug("Removing '#{var}' => '#{value}' from environment")
        end

        each do |k, v|
          Log.debug("Adding '#{k}' => '#{v}' to environment")
          ENV[k] = v
        end

        yield
      ensure
        ENV.replace(saved_env.to_hash)
      end

      def to_hash
        Hash[self]
      end
    end
  end
end
