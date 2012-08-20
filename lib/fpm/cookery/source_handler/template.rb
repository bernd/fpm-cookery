require 'fpm/cookery/utils'

module FPM
  module Cookery
    class SourceHandler
      class Template
        include FPM::Cookery::Utils

        NAME = :template
        CHECKSUM = true

        attr_reader :url, :options, :cachedir, :builddir, :has_checksum, :name

        def initialize(source_url, options, cachedir, builddir)
          @url = source_url
          @options = options
          @cachedir = cachedir
          @builddir = builddir
          @has_checksum = self.class::CHECKSUM
          @name = self.class::NAME
        end

        def source
          @url
        end

        def fetch
          raise "#{self}#fetch not implemented!"
        end

        def extract
          raise "#{self}#extract not implemented!"
        end

        def checksum?
          @has_checksum
        end

        def local_path
          @local_path ||= cachedir/(options[:as] || File.basename(url))
        end
      end
    end
  end
end
