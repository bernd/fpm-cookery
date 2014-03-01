require 'fpm/package/npm'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class NPM < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::NPM.new
        end

        def package_setup
          fpm.version = recipe.version
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
