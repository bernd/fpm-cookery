require 'fpm/cookery/log'

module FPM
  module Cookery
    module LifecycleHooks
      def run_lifecycle_hook(hook_name)
        Log.debug("Run lifecycle hook: #{hook_name}")
        self.__send__(hook_name)
      end

      def before_dependency_installation
      end

      def after_dependency_installation
      end
    end
  end
end
