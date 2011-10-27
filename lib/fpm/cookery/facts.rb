require 'facter'

module FPM
  module Cookery
    class Facts
      def self.platform
        @platform ||= Facter.fact(:operatingsystem).value.downcase.to_sym
      end

      def self.platform=(value)
        @platform= value
      end

      def self.reset!
        instance_variables.each {|v| instance_variable_set(v, nil) }
      end
    end
  end
end
