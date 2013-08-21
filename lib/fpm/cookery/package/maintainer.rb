require 'fpm/cookery/shellout'

module FPM
  module Cookery
    module Package
      class Maintainer < Struct.new(:recipe, :config)
        def maintainer
          config_maintainer || recipe_maintainer || git_maintainer
        end

        def to_s
          maintainer
        end
        alias_method :to_str, :to_s

        private

        def config_maintainer
          config[:maintainer]
        end

        def recipe_maintainer
          recipe.maintainer
        end

        def git_maintainer
          username = git_config('user.name')
          useremail = git_config('user.email')

          username && useremail ? "#{username} <#{useremail}>" : nil
        end

        def git_config(key)
          FPM::Cookery::Shellout.git_config_get(key)
        end
      end
    end
  end
end
