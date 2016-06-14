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

      # If the Addressable::URI is empty, there's nothing to fetch
      def fetchable?
        !@url.empty?
      end

      def url
        @url.to_s
      end
      [:to_s, :to_str].each { |m| alias_method m, :url }

      def path
        @url.path
      end
    end
  end
end
