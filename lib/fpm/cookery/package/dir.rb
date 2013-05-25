require 'fpm/package/dir'
require 'delegate'

module FPM
  module Cookery
    module Package
      class Dir < SimpleDelegator
        def initialize(recipe, config = {})
          super(FPM::Package::Dir.new)

          self.name = recipe.name
          self.url = recipe.homepage || recipe.source
          self.category = recipe.section || 'optional'
          self.description = recipe.description.strip if recipe.description
          self.architecture = recipe.arch.to_s if recipe.arch

          self.dependencies += recipe.depends
          self.conflicts += recipe.conflicts
          self.provides += recipe.provides
          self.replaces += recipe.replaces
          self.config_files += recipe.config_files

          attributes[:prefix] = '/'
          attributes[:chdir] = recipe.destdir.to_s
          attributes[:deb_compression] = 'gzip'
          attributes[:deb_user] = 'root'
          attributes[:deb_group] = 'root'
          attributes[:rpm_compression] = 'gzip'
          attributes[:rpm_digest] = 'md5'
          attributes[:rpm_user] = 'root'
          attributes[:rpm_group] = 'root'
          attributes[:rpm_defattrfile] = '-'
          attributes[:rpm_defattrdir] = '-'

          # TODO replace remove_excluded_files() in packager with this.
          attributes[:excludes] = []

          inputs = config.fetch(:input, nil) || '.'

          Array(inputs).each do |path|
            input(path)
          end

          # The call to input() overwrites the license and vendor attributes.
          # XXX Needs to be fixed in fpm/package/dir.rb.
          self.license = recipe.license if recipe.license
        end
      end
    end
  end
end
