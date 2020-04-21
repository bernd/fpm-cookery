require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class MultiSource < FPM::Cookery::SourceHandler::Template
        NAME = :multi_source
        CHECKSUM = false

        def initialize(source_url, options, cachedir, builddir)
          super

          @source_handlers = []

          source.url.each do |url|
            klass = FPM::Cookery::SourceHandler.handler_to_class(url[:with])

            @source_handlers << klass.new(url[:url], url, cachedir, builddir)
          end
        end

        def fetch(config = {})
          Log.info "multi_source handler; fetching..."

          @source_handlers.each do |source_handler|
            source_handler.fetch(config)
          end

          Log.info "multi_source handler; fetch complete"
        end

        def extract(config = {})
          Log.info "multi_source handler; extracting..."

          extracted = builddir

          @source_handlers.each do |source_handler|
            if source_handler.options[:main]
              extracted = source_handler.extract(config)
            else
              source_handler.extract(config)
            end
          end

          extracted
        end

      end
    end
  end
end
