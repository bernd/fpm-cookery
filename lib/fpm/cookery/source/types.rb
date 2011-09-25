require 'fpm/cookery/source_type/http'

module FPM
  module Cookery
    module Source
      class Types
        def self.new_type_for(source_url, options)
          case source_url
          when 'NONE YET'
          else
            SourceType::HTTP.new(source_url, options)
          end
        end
      end
    end
  end
end
