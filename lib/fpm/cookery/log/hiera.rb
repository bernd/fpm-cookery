require 'hiera'
require 'fpm/cookery/log'

module FPM
  module Cookery
    module Log
      module Hiera
        extend SingleForwardable

        # These are the methods that Hiera requires to be defined
        def_delegators FPM::Cookery::Log, :warn, :debug

        module_function

        def suitable?
          defined?(::FPM::Cookery) == "constant"
        end
      end
    end
  end
end
