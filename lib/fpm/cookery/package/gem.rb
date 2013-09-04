require 'fpm/package/gem'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Gem < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::Gem.new
        end

        def package_setup
          fpm.version = recipe.version

          fpm.attributes[:gem_fix_name?] = true
          fpm.attributes[:gem_fix_dependencies?] = true
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
