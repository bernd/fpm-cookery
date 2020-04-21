require 'addressable/uri'

module FPM
  module Cookery
    class Source
      attr_reader :provider, :options

      def initialize(url, options = nil)
        options ||= {}

        if url.is_a? Array
          @url = url
          @provider = :multi_source
        else
          @url = Addressable::URI.parse(url.to_s)
          @provider = options[:with]
        end

        @options = options
      end

      def provider?
        !!@provider
      end

      def local?
        @url.scheme.to_s.downcase == 'file'
      end

      # If the Addressable::URI is empty, there's nothing to fetch
      def fetchable?
        !@url.empty?
      end

      def url
        @provider == :multi_source ? @url : @url.to_s
      end
      [:to_s, :to_str].each { |m| alias_method m, :url }

      def path
        @url.path
      end
    end
  end
end
