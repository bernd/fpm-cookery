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

      def self.osrelease
        @osrelease ||= Facter.fact(:operatingsystemrelease).value
      end

      def self.lsbcodename
        codename = Facter.fact(:lsbcodename)

        @lsbcodenode ||= codename.nil? ? nil : codename.value.downcase.to_sym
      end

      def self.osmajorrelease
        @osmajorrelease ||= Facter.fact(:operatingsystemmajrelease).value
      end

      def self.target
        @target ||= case platform
                    when :centos, :redhat, :fedora, :amazon,
                         :scientific, :oraclelinux           then :rpm
                    when :debian, :ubuntu                    then :deb
                    when :darwin                             then :osxpkg
                    when :alpine                             then :apk
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
