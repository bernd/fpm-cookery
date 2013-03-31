require 'forwardable'
require 'fpm/cookery/source_handler/curl'
require 'fpm/cookery/source_handler/svn'
require 'fpm/cookery/source_handler/git'
require 'fpm/cookery/source_handler/hg'
require 'fpm/cookery/source_handler/local_path'
require 'fpm/cookery/source_handler/noop'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      DEFAULT_HANDLER = :curl
      LOCAL_HANDLER = :local_path

      extend Forwardable
      def_delegators :@handler, :fetch, :extract, :local_path, :checksum?

      attr_reader :source_url

      def initialize(source, cachedir, builddir)
        @source = source
        @cachedir = cachedir
        @builddir = builddir

        if @source.provider?
          @source_provider = @source.provider
        elsif @source.local?
          @source_provider = LOCAL_HANDLER
        else
          @source_provider = DEFAULT_HANDLER
        end

        @handler = get_source_handler(@source_provider)
      end

      private
      def get_source_handler(provider)
        klass = handler_to_class(provider)
        # XXX Refactor handler to avoid passing the options.
        klass.new(@source, @source.options, @cachedir, @builddir)
      end

      def handler_to_class(provider)
        begin
          self.class.const_get(provider.to_s.split('_').map(&:capitalize).join)
        rescue NameError
          Log.error "Specified provider #{provider} does not exist."
          exit(1)
        end
      end
    end
  end
end
