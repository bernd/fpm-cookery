require 'fpm/package/dir'
require 'delegate'

module FPM
  module Cookery
    module Package
      class Dir < SimpleDelegator
        def initialize(recipe)
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
          attributes[:rpm_compression] = 'gzip'
          attributes[:rpm_digest] = 'md5'
          attributes[:rpm_user] = 'root'
          attributes[:rpm_group] = 'root'

          # TODO replace remove_excluded_files() in packager with this.
          attributes[:excludes] = []

          input('.')
        end
      end
    end
  end
end
