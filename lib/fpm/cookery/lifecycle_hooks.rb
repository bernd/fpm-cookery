require 'fpm/cookery/log'

module FPM
  module Cookery
    module LifecycleHooks
      def run_lifecycle_hook(hook_name, *args)
        Log.debug("Run lifecycle hook: #{hook_name} (args: #{args.inspect})")
        self.__send__(hook_name, *args)

        # Backward compatibility for users of deprecated lifecycle hooks
        case hook_name
        when :before_package_file_create
          unless self.__send__(:before_package_create, args[1]) == :UNUSED
            Log.deprecated("Switch from \"before_package_create\" lifecycle hook to \"before_package_file_create\"")
          end
        when :after_package_file_create
          unless self.__send__(:after_package_create, args[1]) == :UNUSED
            Log.deprecated("Switch from \"after_package_create\" lifecycle hook to \"after_package_file_create\"")
          end
        end
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

      # Gets a the output filename and the FPM::Package object as argument.
      def before_package_file_create(filename, package)
      end

      # Gets a the output filename and the FPM::Package object as argument.
      def after_package_file_create(filename, package)
      end

      # Gets a FPM::Package object as argument.
      # @deprecated Use #after_package_file_create.
      def before_package_create(package)
        :UNUSED
      end

      # Gets a FPM::Package object as argument.
      # @deprecated Use #after_package_file_create.
      def after_package_create(package)
        :UNUSED
      end
    end
  end
end
