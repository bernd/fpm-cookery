require 'fpm/cookery/path'
require 'fpm/cookery/utils'

module FPM
  module Cookery
    module SourceType
      class Template
        include FPM::Cookery::Utils

        DEFAULTS = {
          :extract => true
        }

        attr_reader :url, :options

        def initialize(source_url, options)
          @options = DEFAULTS.merge(options)
          @url = source_url
          @extract = options[:extract]
        end

        def fetch
          raise "#{self}#fetch not implemented!"
        end

        def extract
          raise "#{self}#extract not implemented!"
        end

        def cachedir(path = nil)
          Path.pwd/path
        end

        def local_path
          @local_path ||= cachedir(options[:as] || File.basename(url))
        end
      end
    end
  end
end
