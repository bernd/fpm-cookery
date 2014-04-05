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
        end

        def package_input
          fpm.input(recipe.pypi_name || recipe.name)
        end
      end
    end
  end
end
