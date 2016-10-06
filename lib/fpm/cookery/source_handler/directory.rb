require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'
require 'fpm/cookery/path'
require 'fileutils'

module FPM
  module Cookery
    class SourceHandler
      class Directory < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :directory

        def fetch(config = {})
          cachedir
        end

        def extract(config = {})
          path = FPM::Cookery::Path.new(source.path)

          unless path.absolute?
            Log.error("Source path needs to be absolute: #{source.path}")
            raise "Source path needs to be absolute: #{source.path}"
          end

          Log.info("Copying files from #{path}")
          FileUtils.cp_r(path, builddir)
          builddir
        end
      end
    end
  end
end
