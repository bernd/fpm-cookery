require 'fpm/cookery/packager'
require 'fpm/cookery/omnibus_packager'

module FPM
  module Cookery
    class ChainPackager
      include FPM::Cookery::Utils

      attr_reader :packager, :recipe, :config

      def initialize(packager, config = {})
        @packager = packager
        @recipe = packager.recipe
        @config = config
      end

      def run
        Log.info "Recipe #{recipe.name} is a chain package; looking for child recipes to build"

        recipe.chain_recipes.each do |name|
          recipe_file = build_recipe_file_path(name)

          unless File.exists?(recipe_file)
            Log.fatal "Cannot find a recipe for #{name} at #{recipe_file}"
            exit 1
          end

          Log.info "Located recipe at #{recipe_file} for child recipe #{name}; starting build"

          FPM::Cookery::Book.instance.load_recipe(recipe_file) do |dep_recipe|
            depPackager = FPM::Cookery::Packager.new(dep_recipe, config)
            depPackager.target = FPM::Cookery::Facts.target.to_s

            #Chain, chain, chain ...
            if dep_recipe.omnibus_package == true
              FPM::Cookery::OmnibusPackager.new(depPackager, config).run
            elsif dep_recipe.chain_package == true
              FPM::Cookery::ChainPackager.new(depPackager, config).run
            else
              depPackager.dispense
            end
          end

          Log.info "Finished building #{name}, moving on to next recipe"
        end

        packager.dispense
      end

      private

      def build_recipe_file_path(name)
        # Look for recipes in the same dir as the recipe we loaded
        File.expand_path(File.dirname(recipe.filename) + "/#{name}.rb")
      end
    end
  end
end
