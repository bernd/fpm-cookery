require 'fpm/cookery/log'

module FPM
  module Cookery
    module LifecycleHooks
      def run_lifecycle_hook(hook_name, *args)
        Log.debug("Run lifecycle hook: #{hook_name} (args: #{args.inspect})")
        self.__send__(hook_name, *args)
      end

      def before_dependency_installation
      end

      def after_dependency_installation
      end

      # Gets a FPM::Package object as argument.
      def before_package_create(package)
      end

      # Gets a FPM::Package object as argument.
      def after_package_create(package)
      end
    end
  end
end
