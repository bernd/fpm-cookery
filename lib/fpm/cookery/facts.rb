require 'facter'

module FPM
  module Cookery
    class Facts
      def self.arch
        @arch ||= Facter.fact(:architecture).value.downcase.to_sym
      end

      def self.platform
        @platform ||= Facter.fact(:operatingsystem).value.downcase.to_sym
      end

      def self.platform=(value)
        @platform = value.downcase.to_sym
      end

      def self.target
        @target ||= case platform
                    when :centos, :redhat, :fedora then :rpm
                    when :debian, :ubuntu          then :deb
                    end
      end

      def self.target=(value)
        @target = value.to_sym
      end

      def self.reset!
        instance_variables.each {|v| instance_variable_set(v, nil) }
      end
    end
  end
end
