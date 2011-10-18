require 'digest/sha1'

module FPM
  module Cookery
    class SourceIntegrityCheck
      attr_reader :checksum_expected, :checksum_actual, :filename, :digest

      def initialize(recipe)
        @recipe = recipe
        @error = false
        @filename = recipe.local_path
        @digest = nil
        @checksum_expected = nil
        @checksum_actual = nil
        verify!
      end

      def error?
        @error
      end

      def checksum_missing?
        checksum_expected.nil?
      end

      private
      def verify!
        digest, checksum = get_checksum

        @digest = digest
        @checksum_expected = checksum
        @checksum_actual = build_checksum(digest)

        unless digest
          @error = true
          @digest = :sha256
          @checksum_actual = build_checksum(@digest)
        end

        if @checksum_expected.to_s != @checksum_actual.to_s
          @error = true
        end
      end

      def get_checksum
        type = [:sha256, :sha1, :md5].find do |digest|
          @recipe.respond_to?(digest) and
          @recipe.send(digest) and
          !@recipe.send(digest).empty?
        end

        [type, @recipe.send(type)]
      rescue TypeError
        [nil, nil]
      end

      def build_checksum(type)
        return unless type

        digest = Digest.const_get(type.to_s.upcase).new

        File.open(@recipe.local_path, 'r') do |file|
          while chunk = file.read(4096)
            digest.update(chunk)
          end
        end

        digest.hexdigest
      end
    end
  end
end
