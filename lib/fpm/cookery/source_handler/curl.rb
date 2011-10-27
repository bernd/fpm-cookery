require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class Curl < FPM::Cookery::SourceHandler::Template
        def fetch
          unless local_path.exist?
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
            when '.zip'
              safesystem('unzip', '-d', local_path.basename('.zip'), local_path)
            end
          end
          extracted_source
        end

        private
        def curl(url, path)
          safesystem('curl', '-fL', '--progress-bar', '-o', path, url)
        end

        def extracted_source
          entries = Dir['*'].select {|dir| File.directory?(dir) }

          case entries.size
          when 0
            raise "Empty archive! (#{local_path})"
          when 1
            entries.first
          else
            ext = Path.new(url).extname
            dir = local_path.basename(ext)

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
