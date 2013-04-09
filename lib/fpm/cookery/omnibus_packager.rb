require 'fpm/cookery/packager'
require 'fpm/cookery/facts'

module FPM
  module Cookery
    class OmnibusPackager
      include FPM::Cookery::Utils

      attr_reader :packager, :recipe

      def initialize(packager)
        @packager = packager
        @recipe = packager.recipe
        @depends = []
      end

      def run
        # Omnibus packages are many builds in one package; e.g. Ruby + Puppet together.
        Log.info "Recipe #{recipe.name} is an Omnibus package; looking for child recipes to build"

        recipe.omnibus_recipes.each do |name|
          recipe_file = build_recipe_file_path(name)

          unless File.exists?(recipe_file)
            Log.fatal "Cannot find a recipe for #{name} at #{recipe_file}"
            exit 1
          end

          FPM::Cookery::Book.instance.load_recipe(recipe_file) do |dep_recipe|
            dep_recipe.destdir = "#{recipe.omnibus_dir}/embedded" if recipe.omnibus_dir
            dep_recipe.omnibus_installing = true if recipe.omnibus_dir

            pkg = FPM::Cookery::Packager.new(dep_recipe, :skip_package => true, :keep_destdir => true)
            pkg.target = FPM::Cookery::Facts.target.to_s

            Log.info "Located recipe at #{recipe_file} for child recipe #{name}; starting build"
            pkg.dispense

            @depends += dep_recipe.depends
            Log.info "Finished building #{name}, moving on to next recipe"
          end
        end

        # Now all child recipes are built; set depends to combined set of dependencies
        recipe.class.depends(@depends.flatten.uniq)
        Log.info "Combined dependencies: #{recipe.depends.join(', ')}"

        recipe.destdir = recipe.omnibus_dir if recipe.omnibus_dir

        if recipe.omnibus_additional_paths
          packager.config[:input] = [ recipe.destdir ] + recipe.omnibus_additional_paths
        else
          packager.config[:input] = recipe.destdir
        end

        packager.config[:keep_destdir] = true

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
