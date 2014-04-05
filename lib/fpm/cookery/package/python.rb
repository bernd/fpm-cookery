require 'fpm/package/python'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Python < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::Python.new
        end

        def package_setup
          fpm.version = recipe.version

          fpm.attributes[:python_fix_name?] = true
          fpm.attributes[:python_fix_dependencies?] = true
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
