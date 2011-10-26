require 'forwardable'
require 'fpm/cookery/source_handler/curl'
require 'fpm/cookery/source_handler/svn'

module FPM
  module Cookery
    class SourceHandler
      extend Forwardable
      def_delegators :@handler, :fetch, :extract, :local_path, :checksum?

      def initialize(source_url, options, cachedir, builddir, handler)
        @source_url = source_url
        @options = options
        @cachedir = cachedir
        @builddir = builddir
        @handler = get_source_handler(handler)
      end

      private
      def get_source_handler(handler)
        # TODO(lusis) implement SourceHandler registration
        # Conditionals work for now
        # DRY constructor args
        puts "Calling handler #{handler} for source #{@source_url}"
        case handler
        when :curl
          SourceHandler::Curl.new(@source_url, @options, @cachedir, @builddir)
        when :svn
          SourceHandler::Svn.new(@source_url, @options, @cachedir, @builddir)
        else
          SourceHandler::Curl.new(@source_url, @options, @cachedir, @builddir)
        end
      end
    end
  end
end
