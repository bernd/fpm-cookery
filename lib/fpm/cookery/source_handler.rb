require 'forwardable'
require 'fpm/cookery/source_handler/curl'
require 'fpm/cookery/source_handler/svn'
require 'fpm/cookery/source_handler/git'
require 'fpm/cookery/source_handler/hg'
require 'fpm/cookery/source_handler/local_path'
require 'fpm/cookery/source_handler/noop'
require 'fpm/cookery/source_handler/directory'
require 'fpm/cookery/log'
require 'fpm/cookery/exceptions'

module FPM
  module Cookery
    class SourceHandler
      DEFAULT_HANDLER = :curl
      LOCAL_HANDLER = :local_path
      REQUIRED_METHODS = [:fetch, :extract]

      extend Forwardable
      def_delegators :@handler, :fetch, :extract, :local_path, :checksum?
      def_delegators :@source, :fetchable?

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
          maybe_klass = self.class.const_get(provider.to_s.split('_').map(&:capitalize).join)

          instance_method_map = Hash[maybe_klass.instance_methods.map { |m| [m, true] }]
          missing_methods = REQUIRED_METHODS.find_all { |m| !instance_method_map.key?(m) }

          unless missing_methods.empty?
            formatted_missing = missing_methods.map { |m| "`#{m}'" }.join(', ')
            message = %{#{maybe_klass} does not implement required method(s): #{formatted_missing}}
            Log.error message
            raise Error::Misconfiguration, message
          end

          maybe_klass
        rescue NameError => e
          Log.error "Specified provider #{provider} does not exist."
          raise Error::Misconfiguration, e.message
        end
      end
    end
  end
end
