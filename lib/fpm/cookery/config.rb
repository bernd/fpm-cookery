require 'yaml'
require 'fpm/cookery/exceptions'

module FPM
  module Cookery
    class Config
      ATTRIBUTES = [
        :color, :debug, :target, :platform, :maintainer, :vendor,
        :skip_package, :keep_destdir, :dependency_check
      ].freeze

      DEFAULTS = {
        :color => true,
        :debug => false,
        :dependency_check => true,
        :skip_package => false,
        :keep_destdir => false
      }.freeze

      def self.load_file(paths)
        path = Array(paths).find {|p| File.exist?(p) }

        path ? new(YAML.load_file(path)) : new
      end

      def self.from_cli(cli)
        new.tap do |config|
          ATTRIBUTES.each do |name|
            if cli.respond_to?("#{name}?")
              value = cli.__send__("#{name}?")
            elsif cli.respond_to?(name)
              value = cli.__send__(name)
            else
              value = nil
            end

            config.__send__("#{name}=", value) unless value.nil?
          end
        end
      end

      attr_accessor *ATTRIBUTES

      ATTRIBUTES.each do |name|
        class_eval %Q(
          def #{name}?
            !!#{name}
          end
        )
      end

      def initialize(data = {})
        validate_input(data)

        DEFAULTS.merge(data).each do |key, value|
          self.__send__("#{key}=", value)
        end
      end

      def to_hash
        ATTRIBUTES.inject({}) do |hash, attribute|
          hash[attribute] = __send__(attribute)
          hash
        end
      end

      private

      def validate_input(data)
        errors = []

        data.keys.each do |key|
          unless ATTRIBUTES.include?(key.to_sym)
            errors << key
          end
        end

        unless errors.empty?
          e = Error::InvalidConfigKey.new("Invalid config keys: #{errors.join(', ')}")
          e.invalid_keys = errors
          raise e
        end
      end
    end
  end
end
