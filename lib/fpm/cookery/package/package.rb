require 'delegate'

module FPM
  module Cookery
    module Package
      class Package < SimpleDelegator

        def initialize(recipe, delegator, config = {})
          super(delegator)

          self.name = recipe.name
          self.url = recipe.homepage
          self.category = recipe.section || 'optional'
          self.description = recipe.description.strip if recipe.description
          self.architecture = recipe.arch.to_s if recipe.arch

          self.dependencies += recipe.depends
          self.conflicts += recipe.conflicts
          self.provides += recipe.provides
          self.replaces += recipe.replaces
          self.config_files += recipe.config_files

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
        end
      end
    end
  end
end