require 'fpm/cookery/facts'

module FPM
  module Cookery
    class DependencyInspector
      # Inspect dependencies!
      # FPM::Cookery::Packager calls:
      # DependencyInspector.verify!(recipe.depends, recipe.build_depends)
      def verify!(depends, build_depends)
        # Do some work here
      end
    end
  end
end
