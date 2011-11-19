module FPM
  module Cookery
    module Log
      module Output
        class Null
          def method_missing(*args)
          end
        end
      end
    end
  end
end
