require 'addressable/uri'
require 'uri/ssh_git'

module FPM
  module Cookery
    class Source
      attr_reader :provider, :options

      def initialize(url, options = nil)
        options ||= {}
        begin
          @url = Addressable::URI.parse(url.to_s)
        rescue Addressable::URI::InvalidURIError
          @url = URI::SshGit.parse(url.to_s)
        end
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
