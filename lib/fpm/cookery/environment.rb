require 'fpm/cookery/log'

module FPM
  module Cookery
    class Environment
      REMOVALS = %w(
        BUNDLE_GEMFILE RUBYOPT BUNDLE_BIN_PATH GEM_HOME GEM_PATH
      ).freeze

      def initialize
        @env = {}
      end

      def [](key)
        @env[key.to_s]
      end

      def []=(key, value)
        if value.nil?
          @env.delete(key.to_s)
        else
          @env[key.to_s] = value.to_s
        end
      end

      def with_clean
        saved_env = ENV.to_hash

        REMOVALS.each do |var|
          value = ENV.delete(var)
          Log.debug("Removing '#{var}' => '#{value}' from environment")
        end

        @env.each do |k, v|
          Log.debug("Adding '#{k}' => '#{v}' to environment")
          ENV[k] = v
        end

        yield
      ensure
        ENV.replace(saved_env.to_hash)
      end

      def to_hash
        @env.dup
      end
    end
  end
end
