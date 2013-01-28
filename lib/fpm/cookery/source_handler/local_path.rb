require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'
require 'fileutils'

module FPM
  module Cookery
    class SourceHandler
      class LocalPath < FPM::Cookery::SourceHandler::Curl
        CHECKSUM = false
        NAME = :local_path

        def fetch
          if local_path.exist?
            Log.info "Using cached file #{local_path}"
          else
            Log.info "Copying #{source.path} to cache"
            FileUtils.cp_r(source.path, cachedir)
          end
          local_path
        end
      end
    end
  end
end
