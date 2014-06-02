require 'fpm/package/cpan'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class CPAN < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::CPAN.new
        end

        def package_setup
          # Other attributes may be passed via fpm_attributes
          fpm.version = recipe.version
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
