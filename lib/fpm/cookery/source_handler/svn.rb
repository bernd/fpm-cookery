require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class Svn < FPM::Cookery::SourceHandler::Template

        # TODO(lusis)
        # make vcs revision an attribute that gets passed in?
        # How best to do that universally?
        def fetch
          # TODO(lusis) - implement some caching using 'svn info'?
          Dir.chdir(cachedir) do
            svn(url, local_path)
          end
          @has_checksum = false
        end

        def extract
          Dir.chdir(builddir) do
            safesystem('cp', '-Rp', local_path, '.')
          end
          extracted_source
        end

        private
        def svn(url, path)
          real_url, revision = parse_url(url)
          safesystem('svn', 'export', '--force', '-q', '-r', revision, real_url, path)
        end

        def parse_url(url)
          # This makes some pretty bold assumption.
          # urls for repos will NOT have any query strings other than the single revision
          # Totally need to fix this
          require 'uri'
          u = URI.parse(url)
          if u.query.nil?
            [url, 'HEAD']
          else
            [url.chomp("?#{u.query}"), u.query]
          end
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
