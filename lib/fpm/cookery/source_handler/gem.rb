require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      class Gem < FPM::Cookery::SourceHandler::Template
        NAME = :gem
        CHECKSUM = true

        def fetch
          name = options[:name]
          version = options[:version]

          if local_path.exist?
            Log.info "Using cached file #{local_path}"
          else
            Dir.chdir(cachedir) do
              gem(name, version, url) unless local_path.exist?
            end
          end
          
          local_path
        end

        def extract
          FileUtils.cp(local_path, '.')
          Dir.pwd
        end

        private
        def gem(name, version, source)
          safesystem('gem', 'fetch', name, '-v', version, '--source', source)
        end
      end
    end
  end
end
