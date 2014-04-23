require 'fpm/package/dir'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class Dir < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::Dir.new
        end

        def package_setup
          fpm.attributes[:prefix] = '/'
          fpm.attributes[:chdir] = recipe.destdir.to_s
          fpm.attributes[:rpm_sign?] = recipe.rpm_sign if recipe.rpm_sign
        end

        def package_input
          inputs = config.fetch(:input, nil) || '.'

          Array(inputs).each do |path|
            fpm.input(path)
          end
        end
      end
    end
  end
end
