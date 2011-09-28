require 'fpm/cookery/utils'

module FPM
  module Cookery
    class SourceHandler
      class Template
        include FPM::Cookery::Utils

        attr_reader :url, :options, :cachedir, :builddir

        def initialize(source_url, options, cachedir, builddir)
          @url = source_url
          @options = options
          @cachedir = cachedir
          @builddir = builddir
        end

        def fetch
          raise "#{self}#fetch not implemented!"
        end

        def extract
          raise "#{self}#extract not implemented!"
        end

        def local_path
          @local_path ||= cachedir/(options[:as] || File.basename(url))
        end
      end
    end
  end
end
