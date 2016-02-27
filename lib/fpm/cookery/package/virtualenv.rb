require 'fpm/package/virtualenv'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Virtualenv < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::Virtualenv.new
        end

        def package_setup
          fpm.version = recipe.version
          fpm.attributes[:virtualenv_pypi] = recipe.virtualenv_pypi unless recipe.virtualenv_pypi.nil?
          fpm.attributes[:virtualenv_pypi_extra_index_urls] = recipe.virtualenv_pypi_extra_index_urls unless recipe.virtualenv_pypi_extra_index_urls.nil?
          fpm.attributes[:virtualenv_install_location] = recipe.virtualenv_install_location unless recipe.virtualenv_install_location.nil?
          fpm.attributes[:virtualenv_fix_name?] = false
          fpm.attributes[:virtualenv_package_name_prefix] = recipe.virtualenv_package_name_prefix unless recipe.virtualenv_package_name_prefix.nil?
          fpm.attributes[:virtualenv_other_files_dir] = recipe.virtualenv_other_files_dir unless recipe.virtualenv_other_files_dir.nil?
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
