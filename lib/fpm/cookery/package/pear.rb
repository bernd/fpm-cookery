require 'fpm/package/pear'
require 'fpm/cookery/package/package'

module FPM
  module Cookery
    module Package
      class PEAR < FPM::Cookery::Package::Package
        def fpm_object
          FPM::Package::PEAR.new
        end

        def package_setup
          fpm.version = recipe.version
          # Other attributes may be passed via fpm_attributes
          fpm.attributes[:pear_package_name_prefix] = recipe.pear_package_name_prefix unless recipe.pear_package_name_prefix.nil?
          fpm.attributes[:pear_channel]             = recipe.pear_channel unless recipe.pear_channel.nil?
          fpm.attributes[:pear_php_dir]             = recipe.pear_php_dir unless recipe.pear_php_dir.nil?
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
