require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'
require 'fileutils'

module FPM
  module Cookery
    class SourceHandler
      class Directory < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :directory

        def fetch(config = {})
            path = source.path
            cached_file = File.join(@cachedir, path)
            if File.exist? cached_file
              Log.info "Using cached file #{cached_file}"
            else
              # Exclude source directory
              path = File.join(path,'.')
              Log.info "Copying #{path} to cache"
              FileUtils.cp_r(path, cachedir)
            end
          cachedir
        end

        def extract(config = {})
          FileUtils.cp_r(File.join(cachedir,'.'), builddir)
          builddir
        end
      end
    end
  end
end
