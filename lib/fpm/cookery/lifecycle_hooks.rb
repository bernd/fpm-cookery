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

      def before_source_download
      end

      def after_source_download
      end

      def before_source_extraction
      end

      # Gets a FPM::Cookery::Path object pointing to the extracted source as argument.
      def after_source_extraction(extracted_source)
      end

      def before_build
      end

      def after_build
      end

      def before_install
      end

      def after_install
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
