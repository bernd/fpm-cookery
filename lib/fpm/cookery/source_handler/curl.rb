require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      class Curl < FPM::Cookery::SourceHandler::Template

        NAME = :curl
        CHECKSUM = true

        def fetch(config = {})
          if local_path.exist?
            Log.info "Using cached file #{local_path}"
          else
            Dir.chdir(cachedir) do
              curl(url, local_path, config) unless local_path.exist?
            end
          end
          local_path
        end

        def extract(config = {})
          Dir.chdir(builddir) do
            case local_path.extname
            when '.bz2', '.gz', '.tgz', '.xz', '.tar'
              safesystem('tar', 'xf', local_path)
            when '.shar', '.bin'
              File.chmod(0755, local_path)
              safesystem(local_path)
            when '.zip'
              safesystem('unzip', '-d', local_path.basename('.zip'), local_path)
            else
              if !local_path.directory? && !local_path.basename.exist?
                Dir.mkdir(local_path.basename)
              end

              FileUtils.cp_r(local_path, local_path.basename)
            end
            extracted_source
          end
        end

        private
        def curl(url, path, config)
          args = options[:args] || '-fL'
          cmd = ['curl', args]
          cmd << (config[:quiet] ? '-s' : '--progress-bar')
          cmd += ['-o', path, url]
          safesystem(*cmd)
        rescue RuntimeError => e
          Log.error("Command failed: #{cmd.join(' ')}")
          raise
        end

        def extracted_source
          entries = Dir['*'].select {|dir| File.directory?(dir) }

          case entries.size
          when 0
            files = Dir['*'].select {|dir| File.file?(dir) }

            if files.size > 0
              builddir
            else
              raise "Empty archive! (#{local_path})"
            end
          when 1
            entries.first
          else
            # Use current dir when more then one dirs being extracted
            Dir.pwd
          end
        end
      end
    end
  end
end
