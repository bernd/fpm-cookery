require 'fpm/package/gem'
require 'fpm/cookery/package/package'
require 'fpm/cookery/utils'

module FPM
  module Cookery
    module Package
      class Gem < FPM::Cookery::Package::Package
        include FPM::Cookery::Utils

        def fpm_object
          FPM::Package::Gem.new
        end

        def package_setup
          fpm.version = recipe.version

          fpm.attributes[:gem_fix_name?] = true
          fpm.attributes[:gem_fix_dependencies?] = true
        end

        def package_input
          with_cleanenv do
            fpm.input(recipe.name)
          end
        end
      end
    end
  end
end
