require 'forwardable'
require 'fpm/cookery/source_handler/curl'

module FPM
  module Cookery
    class SourceHandler
      extend Forwardable
      def_delegators :@handler, :fetch, :extract, :local_path

      def initialize(source_url, options, cachedir, builddir)
        @source_url = source_url
        @options = options
        @cachedir = cachedir
        @builddir = builddir
        @handler = get_source_handler
      end

      private
      def get_source_handler
        case @source_url.to_s
        when 'NONE YET'
        else
          SourceHandler::Curl.new(@source_url, @options, @cachedir, @builddir)
        end
      end
    end
  end
end
