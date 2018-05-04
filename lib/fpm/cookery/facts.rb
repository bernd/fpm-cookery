require 'facter'

module FPM
  module Cookery
    class Facts
      class << self
        def arch
          @arch ||= value(:architecture)
        end

        def platform
          @platform ||= value(:operatingsystem)
        end

        def platform=(value)
          @platform = value.downcase.to_sym
        end

        def osrelease
          @osrelease ||= value(:operatingsystemrelease, false)
        end

        def lsbcodename
          @lsbcodename ||= value(:lsbcodename)
        end

        def osmajorrelease
          @osmajorrelease ||= value(:operatingsystemmajrelease, false)
        end

        def target
          @target ||= case platform
                      when :centos, :redhat, :fedora, :amazon,
                           :scientific, :oraclelinux, :sles    then :rpm
                      when :debian, :ubuntu                    then :deb
                      when :darwin                             then :osxpkg
                      when :alpine                             then :apk
                      end
        end

        def target=(value)
          @target = value.to_sym
        end

        def reset!
          instance_variables.each {|v| instance_variable_set(v, nil) }
        end

        private

        def value(fact_name, symbolize = true)
          v = Facter.value(fact_name)
          return v if v.nil? or !symbolize
          return v.downcase.to_sym
        end
      end
    end
  end
end
