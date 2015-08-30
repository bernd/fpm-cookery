#require 'digest/md5'
#require 'fpm/cookery/recipe_inspector'
require 'fpm/cookery/utils'
require 'fpm/cookery/source_integrity_check'
require 'fpm/cookery/path'
require 'fpm/cookery/log'
require 'fpm/cookery/package/dir'
require 'fpm/cookery/package/version'
require 'fpm/cookery/package/maintainer'
require 'fpm'

module FPM
  module Cookery
    class Packager
      include FPM::Cookery::Utils

      attr_reader :recipe, :config

      def initialize(recipe, config = {})
        @recipe = recipe
        @config = config
      end

      def skip_package?
        !!config[:skip_package]
      end

      def keep_destdir?
        !!config[:keep_destdir]
      end

      def target=(target)
        # TODO(sissel): do sanity checking
        @target = target
      end

      def cleanup
        Log.info "Cleanup!"
        # TODO(sissel): do some sanity checking to make sure we don't
        # accidentally rm -rf the wrong thing.
        FileUtils.rm_rf(recipe.builddir)
        FileUtils.rm_rf(recipe.destdir)
      end

      def dispense
        env = ENV.to_hash
        package_name = "#{recipe.name}-#{recipe.version}"
        platform = FPM::Cookery::Facts.platform
        target = FPM::Cookery::Facts.target

        Log.info "Starting package creation for #{package_name} (#{platform}, #{target})"
        Log.info ''

        recipe.installing = false

        if defined? recipe.source_handler()
          source = recipe.source_handler

          recipe.cachedir.mkdir
          Dir.chdir(recipe.cachedir) do
            recipe.run_lifecycle_hook(:before_source_download)
            Log.info "Fetching source: #{source.source_url}"
            source.fetch(:quiet => config[:quiet])
            recipe.run_lifecycle_hook(:after_source_download)

            if source.checksum?
              SourceIntegrityCheck.new(recipe).tap do |check|
                if check.checksum_missing?
                  Log.warn 'Recipe does not provide a checksum. (sha256, sha1 or md5)'
                  Log.puts <<-__WARN
  Digest:   #{check.digest}
  Checksum: #{check.checksum_actual}
  Filename: #{check.filename}

                  __WARN
                elsif check.error?
                  Log.error 'Integrity check failed!'
                  Log.puts <<-__ERROR
  Digest:            #{check.digest}
  Checksum expected: #{check.checksum_expected}
  Checksum actual:   #{check.checksum_actual}
  Filename:          #{check.filename}

                  __ERROR
                  exit 1
                end #end checksum missing
              end #end check
            end #end checksum
          end #end chdir cachedir

          recipe.builddir.mkdir
          Dir.chdir(recipe.builddir) do
            recipe.run_lifecycle_hook(:before_source_extraction)
            extracted_source = source.extract

            if recipe.extracted_source
              Log.debug "Using custom extracted source dir: #{recipe.builddir(recipe.extracted_source)}"
              extracted_source = recipe.extracted_source
            end

            recipe.run_lifecycle_hook(:after_source_extraction, recipe.builddir(extracted_source))

            Dir.chdir(extracted_source) do
              #Source::Patches.new(recipe.patches).apply!

              build_cookie = build_cookie_name(package_name)

              if File.exists?(build_cookie)
                Log.warn "Skipping build of #{recipe.name} because build cookie found (#{build_cookie})," \
                         " use \"fpm-cook clean\" to rebuild!"
              else
                recipe.run_lifecycle_hook(:before_build)
                Log.info "Building in #{File.expand_path(extracted_source, recipe.builddir)}"
                recipe.build and FileUtils.touch(build_cookie)
                recipe.run_lifecycle_hook(:after_build)
              end

              FileUtils.rm_rf(recipe.destdir) unless keep_destdir?
              recipe.destdir.mkdir unless File.exists?(recipe.destdir)

              begin
                recipe.installing = true
                Log.info "Installing into #{recipe.destdir}"
                recipe.run_lifecycle_hook(:before_install)
                recipe.install
                recipe.run_lifecycle_hook(:after_install)
              ensure
                recipe.installing = false
              end
            end #end chdir extracted_source
          end #end chdir builddir
        end #end defined source_handler

        if skip_package?
          Log.info "Package building disabled"
        else
          build_package(recipe, config)
        end
      ensure
        # Make sure we reset the environment.
        ENV.replace(env)
      end

      def build_cookie_name(name)
        (recipe.builddir/".build-cookie-#{name.gsub(/[^\w]/,'_')}").to_s
      end

      def build_package(recipe, config)
        recipe.pkgdir.mkdir
        Dir.chdir(recipe.pkgdir) do
          version = FPM::Cookery::Package::Version.new(recipe, @target, config)
          maintainer = FPM::Cookery::Package::Maintainer.new(recipe, config)

          input = recipe.input(config)

          input.version = version
          input.maintainer = maintainer.to_s
          input.vendor = version.vendor if version.vendor
          input.epoch = version.epoch if version.epoch

          add_scripts(recipe, input)

          output_class = FPM::Package.types[@target]

          output = input.convert(output_class)

          recipe.run_lifecycle_hook(:before_package_create, output)
          begin
            output.output(output.to_s)
            recipe.run_lifecycle_hook(:after_package_create, output)
          rescue FPM::Package::FileAlreadyExists
            Log.info "Removing existing package file: #{output.to_s}"
            FileUtils.rm_f(output.to_s)
            retry
          ensure
            input.cleanup if input
            output.cleanup if output
            Log.info "Created package: #{File.join(Dir.pwd, output.to_s)}"
          end
        end
      end

      def add_scripts(recipe, input)
        error = false
        scripts = [:pre_install, :post_install, :pre_uninstall, :post_uninstall]

        scripts.each do |script|
          unless recipe.send(script).nil?
            script_file = FPM::Cookery::Path.new(recipe.send(script))

            # If the script file is an absolute path, just use that path.
            # Otherwise consider the location relative to the recipe.
            unless script_file.absolute?
              script_file = File.expand_path("../#{script_file.to_s}", recipe.filename)
            end

            if File.exists?(script_file)
              input.add_script(script, File.read(script_file.to_s))
            else
              Log.error "#{script} script '#{script_file}' is missing"
              error = true
            end
          end
        end

        exit(1) if error
      end
    end
  end
end
