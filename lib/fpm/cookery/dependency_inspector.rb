require 'puppet'
require 'puppet/resource'
require 'puppet/transaction/report'
require 'fpm/cookery/facts'
require 'fpm/cookery/log'

# Init Puppet before using it
Puppet.initialize_settings

module FPM
  module Cookery
    class DependencyInspector

      def self.verify!(depends, build_depends)

        Log.info "Verifying and installing build_depends and depends with Puppet"

        build_depends.each do |package|
          self.install_package(package)
        end

        depends.each do |package|
          self.install_package(package)
        end

      end

      private
      def self.install_package(package)
        # How can we handle "or" style depends?
        if package =~ / \| /
          Log.warn "Required package '#{package}' is an 'or' string; not attempting to install a package to satisfy"
          return
        end
        # Use Puppet to install a package
        resource = Puppet::Resource.new("package", package, :parameters => {
          :ensure => "present"
        })
        result = Puppet::Resource.indirection.save(resource)[1]
        failed = Puppet::Resource.indirection.save(resource)[1].resource_statuses.values.first.failed
        if failed
          Log.fatal "While processing depends package '#{package}':"
          result.logs.each {|log_line| Log.fatal log_line}
        else
          Log.info "Processing depends package '#{package}'"
          result.logs.each {|log_line| Log.info log_line}
        end
      end

    end
  end
end
