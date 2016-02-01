require 'hiera/backend'

module FPM
  module Cookery
    module Hiera
      module Utils
        module_function

        def find_backend(backend)
          return Hiera::Backend.const_get(backend_name(backend)).new
        rescue
          nil
        end

        def backend_name(backend)
          "#{backend.capitalize}_backend".to_sym
        end
      end
    end
  end
end
