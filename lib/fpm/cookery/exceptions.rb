module FPM
  module Cookery
    class Error < StandardError
      MethodNotImplemented = Class.new(self)
    end
  end
end
