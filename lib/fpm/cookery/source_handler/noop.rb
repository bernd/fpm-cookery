require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class Noop < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :noop

        def fetch(config = {})
          Log.info "Noop source_handler; do nothing."
        end

        def extract(config = {})
          Log.info "Not extracting - noop source handler"
          builddir.to_s
        end

        def fetchable?
          true
        end
      end
    end
  end
end
