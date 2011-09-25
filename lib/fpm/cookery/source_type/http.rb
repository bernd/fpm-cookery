require 'fpm/cookery/source_type/template'

module FPM
  module Cookery
    module SourceType
      class HTTP < FPM::Cookery::SourceType::Template
        def fetch
          curl(url, local_path) unless local_path.exist?
          local_path
        end

        def extract
          case local_path.extname
          when '.bz2', '.gz', '.tgz'
            safesystem('tar', 'xf', local_path)
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
