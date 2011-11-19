require 'fpm/cookery/log/output/null'

module FPM
  module Cookery
    module Log
      @output = FPM::Cookery::Log::Output::Null.new

      class << self

        def output(out)
          @output = out
        end

        def debug(message)
          @output.debug(message)
        end

        def info(message)
          @output.info(message)
        end

        def warn(message)
          @output.warn(message)
        end

        def error(message)
          @output.error(message)
        end

        def fatal(message)
          @output.fatal(message)
        end

        def puts(message)
          @output.puts(message)
        end
      end
    end
  end
end
