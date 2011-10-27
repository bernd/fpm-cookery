require 'facter'

module FPM
  module Cookery
    class Facts
      def self.operatingsystem
        @operatingsystem ||= Facter.fact(:operatingsystem).value.downcase.to_sym
      end

      def self.operatingsystem=(value)
        @operatingsystem = value
      end

      def self.reset!
        instance_variables.each {|v| instance_variable_set(v, nil) }
      end
    end
  end
end
