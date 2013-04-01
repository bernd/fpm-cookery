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

        Log.info "Verifying build_depends and depends with Puppet"

        missing = (build_depends + depends).reject do |package|
          self.package_installed?(package)
        end

        if missing.length == 0
          Log.info "All build_depends and depends packages installed"
        else
          Log.info "Missing/wrong version packages: #{missing.join(', ')}"
          if Process.euid != 0
            Log.error "Not running as root; please run 'sudo fpm-cook install-deps' to install dependencies."
            exit 1
          else
            Log.info "Running as root; installing missing/wrong version build_depends and depends with Puppet"
            missing.each do |package|
              self.install_package(package)
            end
          end
        end

      end

      def self.package_installed?(package)
        Log.info("Verifying package: #{package}")
        return unless self.package_suitable?(package)

        # Use Puppet in noop mode to see if the package exists
        Puppet[:noop] = true
        resource = Puppet::Resource.new("package", package, :parameters => {
          :ensure => "present"
        })
        result    = Puppet::Resource.indirection.save(resource)[1]
        !result.resource_statuses.values.first.out_of_sync
      end

      def self.install_package(package)
        Log.info("Installing package: #{package}")
        return unless self.package_suitable?(package)

        # Use Puppet to install a package
        Puppet[:noop] = false
        resource = Puppet::Resource.new("package", package, :parameters => {
          :ensure => "present"
        })
        result = Puppet::Resource.indirection.save(resource)[1]
        failed = Puppet::Resource.indirection.save(resource)[1].resource_statuses.values.first.failed
        if failed
          Log.fatal "While processing depends package '#{package}':"
          result.logs.each {|log_line| Log.fatal log_line}
          exit 1
        else
          result.logs.each {|log_line| Log.info log_line}
        end
      end

      def self.package_suitable?(package)
        # How can we handle "or" style depends?
        if package =~ / \| /
          Log.warn "Required package '#{package}' is an 'or' string; not attempting to find/install a package to satisfy"
          return false
        end

        # We can't handle >=, <<, >>, <=
        if package =~ />=|<<|>>|<=/
          Log.warn "Required package '#{package}' has a relative version requirement; not attempting to find/install a package to satisfy"
          return false
        end
        true
      end

    end
  end
end
