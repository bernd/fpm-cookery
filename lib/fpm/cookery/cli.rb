require 'fpm/cookery/book_hook'
require 'fpm/cookery/recipe'
require 'fpm/cookery/facts'
require 'fpm/cookery/packager'
require 'fpm/cookery/chain_packager'
require 'fpm/cookery/omnibus_packager'
require 'fpm/cookery/log'
require 'fpm/cookery/log/output/console'
require 'fpm/cookery/log/output/console_color'
require 'fpm/cookery/config'
require 'clamp'

module FPM
  module Cookery
    class CLI < Clamp::Command
      option ['-c', '--color'], :flag, 'toggle color'
      option ['-D', '--debug'], :flag, 'enable debug output'
      option ['-t', '--target'], 'TARGET', 'set desired fpm output target (deb, rpm, etc)'
      option ['-p', '--platform'], 'PLATFORM', 'set the target platform (centos, ubuntu, debian)'
      option ['-q', '--quiet'], :flag, 'Disable verbose output like progress bars'
      option ['-V', '--version'], :flag, 'show fpm-cookery and fpm version'
      option '--[no-]install-build-depends', :flag, 'enable/disable installation of build dependencies',
        :attribute_name => 'install_build_depends'
      option '--[no-]install-depends', :flag, 'enable/disable installation of dependencies',
        :attribute_name => 'install_depends'
      option '--tmp-root', 'DIR', 'directory root for temporary files',
        :attribute_name => 'tmp_root'
      option '--pkg-dir', 'DIR', 'directory for built packages',
        :attribute_name => 'pkg_dir'
      option '--cache-dir', 'DIR', 'directory for downloaded sources',
        :attribute_name => 'cache_dir'
      option '--skip-package', :flag, 'do not call FPM to build the package',
        :attribute_name => 'skip_package'

      class Command < self
        def recipe_file
          file = File.expand_path(recipe)

          # Allow giving the directory containing a recipe.rb
          if File.directory?(file) && File.exists?(File.join(file, 'recipe.rb'))
            file = File.join(file, 'recipe.rb')
          end

          file
        end

        def validate
          unless File.exists?(recipe_file)
            Log.error 'No recipe.rb found in the current directory, abort.'
            exit 1
          end

          # Override the detected platform.
          if platform
            FPM::Cookery::Facts.platform = platform
          end

          if target
            FPM::Cookery::Facts.target = target
          end

          if FPM::Cookery::Facts.target.nil?
            Log.error "No target given and we're unable to detect your platform"
            exit 1
          end
        end

        def execute
          show_version if version?
          init_logging
          validate

          FPM::Cookery::BaseRecipe.send(:include, FPM::Cookery::BookHook)

          FPM::Cookery::Book.instance.load_recipe(recipe_file, config) do |recipe|
            packager = FPM::Cookery::Packager.new(recipe, config.to_hash)
            packager.target = FPM::Cookery::Facts.target.to_s

            exec(config, recipe, packager)
          end
        end

        def show_version
          require 'fpm/version'
          require 'fpm/cookery/version'

          puts "fpm-cookery v#{FPM::Cookery::VERSION} (fpm v#{FPM::VERSION})"
          exit 0
        end

        def config
          @config ||= FPM::Cookery::Config.from_cli(self)
        end

        def init_logging
          FPM::Cookery::Log.enable_debug(config.debug)

          if config.color?
            FPM::Cookery::Log.output(FPM::Cookery::Log::Output::ConsoleColor.new)
          else
            FPM::Cookery::Log.output(FPM::Cookery::Log::Output::Console.new)
          end
        end
      end

      class PackageCmd < Command
        parameter '[RECIPE]', 'the recipe file', :default => 'recipe.rb'

        def exec(config, recipe, packager)
          if recipe.omnibus_package == true
            FPM::Cookery::OmnibusPackager.new(packager, config).run
          elsif recipe.chain_package == true
            FPM::Cookery::ChainPackager.new(packager, config).run
          else
            packager.dispense
          end
        end
      end

      class CleanCmd < Command
        parameter '[RECIPE]', 'the recipe file', :default => 'recipe.rb'

        def exec(config, recipe, packager)
          packager.cleanup
        end
      end

      class InstallDepsCmd < Command
        parameter '[RECIPE]', 'the recipe file', :default => 'recipe.rb'

        def exec(config, recipe, packager)
          packager.install_deps
          Log.info('All dependencies installed!')
        end
      end

      class InstallBuildDepsCmd < Command
        parameter '[RECIPE]', 'the recipe file', :default => 'recipe.rb'

        def exec(config, recipe, packager)
          if recipe.omnibus_package == true
            FPM::Cookery::OmnibusPackager.new(packager, config).install_build_deps
          elsif recipe.chain_package == true
            FPM::Cookery::ChainPackager.new(packager, config).install_build_deps
          else
            packager.install_build_deps
          end
          Log.info('Build dependencies installed!')
        end
      end

      class ShowDepsCmd < Command
        parameter '[RECIPE]', 'the recipe file', :default => 'recipe.rb'

        def exec(config, recipe, packager)
          puts recipe.depends_all.join(' ')
        end
      end

      self.default_subcommand = 'package'

      subcommand 'package', 'builds the package', PackageCmd
      subcommand 'clean', 'cleans up', CleanCmd
      subcommand 'install-deps', 'installs build and runtime dependencies', InstallDepsCmd
      subcommand 'install-build-deps', 'installs build dependencies', InstallBuildDepsCmd
      subcommand 'show-deps', 'show build and runtime dependencies', ShowDepsCmd
    end
  end
end
