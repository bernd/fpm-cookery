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
          fpm.attributes[:virtualenv_install_location] = recipe.virtualenv_install_location unless recipe.virtualenv_install_location.nil?
          fpm.attributes[:virtualenv_fix_name?] = false
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
