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

          fpm.attributes[:prefix]                   = recipe.prefix unless recipe.prefix.nil?
          fpm.attributes[:pear_package_name_prefix] = recipe.pear_package_name_prefix unless recipe.pear_package_name_prefix.nil?
          fpm.attributes[:pear_channel]             = recipe.pear_channel unless recipe.pear_channel.nil?
          fpm.attributes[:pear_channel_update?]     = recipe.pear_channel_update unless recipe.pear_channel_update.nil?
          fpm.attributes[:pear_bin_dir]             = recipe.pear_bin_dir unless recipe.pear_bin_dir.nil?
          fpm.attributes[:pear_data_dir]            = recipe.pear_data_dir unless recipe.pear_data_dir.nil?
          fpm.attributes[:pear_php_bin]             = recipe.pear_php_bin unless recipe.pear_php_bin.nil?
          fpm.attributes[:pear_php_dir]             = recipe.pear_php_dir unless recipe.pear_php_dir.nil?
        end

        def package_input
          fpm.input(recipe.name)
        end
      end
    end
  end
end
