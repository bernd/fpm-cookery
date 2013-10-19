require 'fpm/cookery/exceptions'

module FPM
  module Cookery
    module Package
      class Package
        attr_reader :recipe, :config, :fpm

        def initialize(recipe, config = {})
          @recipe = recipe
          @config = config
          @fpm = fpm_object

          @fpm.name = recipe.name
          @fpm.url = recipe.homepage
          @fpm.category = recipe.section || 'optional'
          @fpm.description = recipe.description.strip if recipe.description
          @fpm.architecture = recipe.arch.to_s if recipe.arch

          @fpm.dependencies += recipe.depends
          @fpm.conflicts += recipe.conflicts
          @fpm.provides += recipe.provides
          @fpm.replaces += recipe.replaces
          @fpm.config_files += recipe.config_files

          @fpm.attributes[:deb_compression] = 'gzip'
          @fpm.attributes[:deb_user] = 'root'
          @fpm.attributes[:deb_group] = 'root'
          @fpm.attributes[:rpm_compression] = 'gzip'
          @fpm.attributes[:rpm_digest] = 'md5'
          @fpm.attributes[:rpm_user] = 'root'
          @fpm.attributes[:rpm_group] = 'root'
          @fpm.attributes[:rpm_defattrfile] = '-'
          @fpm.attributes[:rpm_defattrdir] = '-'

          # TODO replace remove_excluded_files() in packager with this.
          @fpm.attributes[:excludes] = []

          # Package type specific code should be called in package_setup.
          package_setup

          # The input for the FPM package will be set here.
          package_input

          # The call to input() overwrites the license and vendor attributes.
          # XXX Needs to be fixed in fpm/package/dir.rb.
          fpm.license = recipe.license if recipe.license
        end

        def fpm_object
          # Has to be overwritten in a subclass.
          raise Error::MethodNotImplemented, "The #fpm_object method has not been implemented in #{self.class}"
        end

        def package_setup
          # Can be overwritten in a subclass.
        end

        def package_input
          # Has to be overwritten in a subclass.
          raise Error::MethodNotImplemented, "The #package_input method has not been implemented in #{self.class}"
        end

        def convert(output_class)
          fpm.convert(output_class)
        end

        def cleanup
          fpm.cleanup
        end

        def add_script(type, content)
          case type.to_sym
          when :pre_install
            fpm.scripts[:before_install] = content
          when :post_install
            fpm.scripts[:after_install] = content
          when :pre_uninstall
            fpm.scripts[:before_remove] = content
          when :post_uninstall
            fpm.scripts[:after_remove] = content
          end
        end

        # XXX should go away and set in initializer
        def version=(value)
          fpm.version = value
        end

        def maintainer=(value)
          fpm.maintainer = value
        end

        def vendor=(value)
          fpm.vendor = value
        end

        def epoch=(value)
          fpm.epoch = value
        end
      end
    end
  end
end
