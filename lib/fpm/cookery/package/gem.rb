require 'fpm/package/gem'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Gem < FPM::Cookery::Package::Package

        def initialize(recipe)
          super(recipe, FPM::Package::Gem.new)

          self.version = recipe.version

          attributes[:gem_fix_name?] = true
          attributes[:gem_fix_dependencies?] = true

          input(self.name)
        end

      end
    end
  end
end
