require 'forwardable'
require 'fpm/cookery/source_handler/curl'
#require 'fpm/cookery/source_handler/svn'

module FPM
  module Cookery
    class SourceHandler
      extend Forwardable
      def_delegators :fetch, :extract, :local_path, :checksum?

      def initialize(source_url, options, cachedir, builddir)
        @source_url = source_url
        @options = options
        @cachedir = cachedir
        @builddir = builddir
        @handler = get_source_handler(options[:with])
      end

      private
      def get_source_handler(handler)
        # TODO(lusis) implement SourceHandler registration
        # Conditionals work for now
        # DRY constructor args
        klass = handler_to_class(handler)
        klass.new(@source_url, @options, @cachedir, @builddir)
      end

      def handler_to_class(handler)
        self.class.const_get(handler.to_s.capitalize)
      end
    end
  end
end
