require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class Svn < FPM::Cookery::SourceHandler::Template

        CHECKSUM = false
        NAME = :svn

        def fetch(config = {})
          # TODO(lusis) - implement some caching using 'svn info'?
          Dir.chdir(cachedir) do
            svn(url, local_path)
          end
          local_path
        end

        def extract(config = {})
          Dir.chdir(builddir) do
            safesystem('cp', '-Rp', local_path, '.')
            extracted_source
          end
        end

        private
        def svn(url, path)
          revision = options[:revision] || 'HEAD'
          safesystem('svn', 'export', '--force', '-q', '-r', revision, url, path)
        end

        def extracted_source
          entries = Dir['*'].select {|dir| File.directory?(dir) }

          case entries.size
          when 0
            raise "Empty checkout! (#{local_path})"
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
