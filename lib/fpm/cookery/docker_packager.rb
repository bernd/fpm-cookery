require 'digest/sha1'
require 'fileutils'
require 'pathname'

require 'fpm/cookery/version'
require 'fpm/cookery/facts'
require 'fpm/cookery/packager'
require 'fpm/cookery/exceptions'

# Runs the package creation inside a Docker container.
module FPM
  module Cookery
    class DockerPackager
      include FPM::Cookery::Utils

      attr_reader :packager, :recipe, :config

      def initialize(recipe, config)
        @recipe = recipe
        @config = config
      end

      def run
        recipe_dir = File.dirname(recipe.filename)

        # The cli settings should have precendence
        image_name = config.docker_image || recipe.docker_image
        cache_paths = get_cache_paths
        docker_bin = config.docker_bin.nil? || config.docker_bin.empty? ? 'docker' : config.docker_bin
        dockerfile = get_dockerfile(recipe_dir)

        if File.exist?(dockerfile)
          image_name = "local/fpm-cookery/#{File.basename(recipe_dir)}:latest"
          Log.info "Building custom Docker image #{image_name} from #{dockerfile}"
          build_cmd = [
            config.docker_bin, 'build',
            '-f', dockerfile,
            '-t', image_name,
            '--force-rm',
            '.'
          ].compact.flatten.join(' ')
          sh build_cmd
        else
          Log.warn "File #{dockerfile} does not exist - not building a custom Docker image"
        end

        if image_name.nil? || image_name.empty?
          image_name = "fpmcookery/#{FPM::Cookery::Facts.platform}-#{FPM::Cookery::Facts.osrelease}:#{FPM::Cookery::VERSION}"
        end

        Log.info "Building #{recipe.name}-#{recipe.version} inside a Docker container using image #{image_name}"
        Log.info "Mounting #{recipe_dir} as /recipe"

        cmd = [
          config.docker_bin, "run", "-ti",
          "--name", "fpm-cookery-build-#{File.basename(recipe_dir)}",
          config.docker_keep_container ? nil : "--rm",
          "-e", "FPMC_UID=#{Process.uid}",
          "-e", "FPMC_GID=#{Process.gid}",
          config.debug ? ["-e", "FPMC_DEBUG=true"] : nil,
          build_cache_mounts(cache_paths),
          "-v", "#{recipe_dir}:/recipe",
          "-w", "/recipe",
          image_name,
          "fpm-cook", "package",
          config.debug ? '-D' : nil,
          File.basename(recipe.filename)
        ].compact.flatten.join(' ')


        Log.debug "Running: #{cmd}"
        begin
          sh cmd
        rescue => e
          Log.debug e
        end
      end

      private

      def get_dockerfile(recipe_dir)
        path = if config.dockerfile.nil? || config.dockerfile.empty?
                 Pathname.new(recipe.dockerfile)
               else
                 Pathname.new(config.dockerfile)
               end

        path.absolute? ? path.to_s : File.join(recipe_dir, path.to_s)
      end

      def get_cache_paths
        if config.docker_cache.nil? || config.docker_cache.empty?
          recipe.docker_cache
        else
          config.docker_cache.split(',').select do |path|
            !path.empty?
          end
        end
      end

      def build_cache_mounts(cache_paths)
        cache_paths.map do |path|
          next if path.nil? || path.empty?
          "-v #{recipe.cachedir}/docker/#{Digest::SHA256.hexdigest(path)}:#{path}"
        end
      end
    end
  end
end
