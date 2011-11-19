#require 'digest/md5'
#require 'fpm/cookery/recipe_inspector'
#require 'fpm/cookery/dependency_inspector'
require 'fpm/cookery/utils'
require 'fpm/cookery/source_integrity_check'
require 'fpm/cookery/path'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class Packager
      include FPM::Cookery::Utils

      attr_reader :recipe, :config

      def initialize(recipe, config = {})
        @recipe = recipe
        @config = config
      end

      def target=(target)
        # TODO(sissel): do sanity checking
        @target = target
      end

      def cleanup
        # TODO(sissel): do some sanity checking to make sure we don't
        # accidentally rm -rf the wrong thing.
        FileUtils.rm_rf(recipe.builddir)
        FileUtils.rm_rf(recipe.destdir)
      end

      def dispense
        env = ENV.to_hash

        # RecipeInspector.verify!(recipe)
        # DependencyInspector.verify!(recipe.depends, recipe.build_depends)

        recipe.installing = false

        source = recipe.source_handler

        recipe.cachedir.mkdir
        Dir.chdir(recipe.cachedir) do
          source.fetch

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
              end
            end
          end
        end

        recipe.builddir.mkdir
        Dir.chdir(recipe.builddir) do
          extracted_source = source.extract

          Dir.chdir(extracted_source) do
            #Source::Patches.new(recipe.patches).apply!

            build_cookie = build_cookie_name("#{recipe.name}-#{recipe.version}")

            if File.exists?(build_cookie)
              Log.info 'Skipping build (`fpm-cook clean` to rebuild)'
            else
              recipe.build and FileUtils.touch(build_cookie)
            end

            FileUtils.rm_rf(recipe.destdir)
            recipe.destdir.mkdir

            begin
              recipe.installing = true
              recipe.install
            ensure
              recipe.installing = false
            end
          end
        end

        build_package(recipe, config)
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
          epoch, ver = recipe.version.split(':', 2)
          if ver.nil?
            ver, epoch = epoch, nil
          end

          # Build a version including vendor and revision.
          vendor = config[:vendor] || recipe.vendor
          vendor_rev = "#{vendor}#{recipe.revision}"
          case @target
          when "deb"
            vendor_delimiter = "+"
          when "rpm"
            vendor_delimiter = "."
          else
            vendor_delimiter = "-"
          end
          version = [ver, vendor_rev].join(vendor_delimiter)

          maintainer = recipe.maintainer || begin
            username = `git config --get user.name`.strip
            useremail = `git config --get user.email`.strip
            raise 'Set maintainer name/email via `git config --global user.name <name>`' if username.empty?
            "#{username} <#{useremail}>"
          end

          # TODO(sissel): This should use an API in fpm. fpm doesn't have this
          # yet.  fpm needs this.
          opts = [
            '-n', recipe.name,
            '-v', version,
            '-t', @target,
            '-s', 'dir',
            '--url', recipe.homepage || recipe.url,
            '-C', recipe.destdir.to_s,
            '--maintainer', maintainer,
            '--category', recipe.section || 'optional',
          ]

          opts += [
            '--epoch', epoch
          ] if epoch

          opts += [
            '--description', recipe.description.strip
          ] if recipe.description

          opts += [
            '--architecture', recipe.arch.to_s
          ] if recipe.arch

          script_map = {"pre_install" => "--pre-install", "post_install" => "--post-install", "pre_uninstall" => "--pre-uninstall", "post_uninstall" => "--post-uninstall"}
          %w[pre_install post_install pre_uninstall post_uninstall].each do |script|
            unless recipe.send(script).nil?
              script_file = FPM::Cookery::Path.new(recipe.send(script))

              # If the script file is an absolute path, just use that path.
              # Otherwise consider the location relative to the recipe.
              unless script_file.absolute?
                script_file = File.expand_path("../#{script_file.to_s}", recipe.filename)
              end

              if File.exists?(script_file)
                p_opt = script_map[script]
                opts += ["#{p_opt}", script_file.to_s]
              else
                raise "#{script} script '#{script_file}' is missing"
              end
            end
          end

          %w[ depends exclude provides replaces conflicts config_files ].each do |type|
            if recipe.send(type).any?
              recipe.send(type).each do |dep|
                opts += ["--#{type.gsub('_','-')}", dep]
              end
            end
          end

          opts << '.'

          Log.info 'Calling fpm to build the package'
          Log.debug ['fpm', opts].flatten.inspect
          safesystem(*['fpm', opts].flatten)
        end
      end
    end
  end
end
