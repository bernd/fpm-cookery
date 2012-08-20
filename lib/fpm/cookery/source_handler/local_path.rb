require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'
require 'fileutils'

module FPM
  module Cookery
    class SourceHandler
      class LocalPath < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :local_path

        def fetch
          # No need to fetch anything. The files are on the disk already.
          Log.info "Local path: #{source.path}"
          @local_path = source.path
        end

        def extract
          extracted_source = (builddir/File.basename(local_path)).to_s

          FileUtils.rm_rf(extracted_source)
          FileUtils.cp_r(source.path, extracted_source)

          extracted_source
        end
      end
    end
  end
end
