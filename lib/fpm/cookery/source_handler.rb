require 'forwardable'
require 'fpm/cookery/source_handler/curl'
require 'fpm/cookery/source_handler/svn'
require 'fpm/cookery/source_handler/git'
require 'fpm/cookery/source_handler/hg'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      DEFAULT_HANDLER = :curl

      extend Forwardable
      def_delegators :@handler, :fetch, :extract, :local_path, :checksum?

      attr_reader :source_url

      def initialize(source_url, options, cachedir, builddir)
        # The reason for these checks is related to the test cases
        # Test cases for individual recipe attributes
        # are not setting spec before hand (due to delegation chain?)
        # Additionally, one test actually has options being sent as a String
        if (options.nil? || options.class == String || options.has_key?(:with) == false)
          @source_provider = DEFAULT_HANDLER
        else
          @source_provider = options[:with]
        end
        @source_url = source_url
        @options = options
        @cachedir = cachedir
        @builddir = builddir
        @handler = get_source_handler(@source_provider)
      end

      private
      def get_source_handler(provider)
        klass = handler_to_class(provider)
        klass.new(@source_url, @options, @cachedir, @builddir)
      end

      def handler_to_class(provider)
        begin
          self.class.const_get(provider.to_s.capitalize)
        rescue NameError
          Log.error "Specified provider #{provider} does not exist."
          exit(1)
        end
      end
    end
  end
end
