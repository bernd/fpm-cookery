module FPM
  module Cookery
    class Error < StandardError
      MethodNotImplemented = Class.new(self)

      class InvalidConfigKey < self
        attr_accessor :invalid_keys
      end
    end
  end
end
