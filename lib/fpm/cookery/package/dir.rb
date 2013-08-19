require 'fpm/package/dir'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Dir < FPM::Cookery::Package::Package
        def initialize(recipe, config = {})
          super(recipe, FPM::Package::Dir.new, config)

          inputs = config.fetch(:input, nil) || '.'

          Array(inputs).each do |path|
            input(path)
          end

          attributes[:prefix] = '/'
          attributes[:chdir] = recipe.destdir.to_s

          # The call to input() overwrites the license and vendor attributes.
          # XXX Needs to be fixed in fpm/package/dir.rb.
          self.license = recipe.license if recipe.license
        end
      end
    end
  end
end
