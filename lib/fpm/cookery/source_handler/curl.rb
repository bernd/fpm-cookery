require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      class Curl < FPM::Cookery::SourceHandler::Template

        NAME = :curl
        CHECKSUM = true

        def fetch
          if local_path.exist?
            Log.info "Using cached file #{local_path}"
          else
            Dir.chdir(cachedir) do
              curl(url, local_path) unless local_path.exist?
            end
          end
          local_path
        end

        def extract
          Dir.chdir(builddir) do
            case local_path.extname
            when '.bz2', '.gz', '.tgz'
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
        def curl(url, path)
          args = options[:args] || '-fL'
          safesystem('curl', args, '--progress-bar', '-o', path, url)
        end

        def extracted_source
          entries = Dir['*'].select {|dir| File.directory?(dir) }

          case entries.size
          when 0
            raise "Empty archive! (#{local_path})"
          when 1
            entries.first
          else
            # Use the directory that was created last.
            dir = entries.sort do |a, b|
              File.stat(a).ctime <=> File.stat(b).ctime
            end.last

            if File.exist?(dir)
              dir
            else
              raise "Could not find source directory for #{local_path.basename}"
            end
          end
        end
      end
    end
  end
end
