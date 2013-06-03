require 'addressable/uri'

module FPM
  module Cookery
    class Source
      attr_reader :provider, :options

      def initialize(url, options = nil)
        options ||= {}
        @url = Addressable::URI.parse(url.to_s)
        @provider = options[:with]
        @options = options
      end

      def provider?
        !!@provider
      end

      def local?
        @url.scheme.to_s.downcase == 'file'
      end

      def url
        @url.to_s
      end

      def path
        @url.path
      end

      def to_s
        @url.to_s
      end

      def to_str
        @url.to_s
      end
    end
  end
end
