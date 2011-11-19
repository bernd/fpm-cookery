
module FPM
  module Cookery
    module Log
      module Output
        class Console
          def debug(message)
            STDOUT.puts "DEBUG: #{message}"
          end

          def info(message)
            STDOUT.puts "===> #{message}"
          end

          def puts(message)
            STDOUT.puts "#{message}"
          end

          def warn(message)
            STDERR.puts "WARNING: #{message}"
          end

          def error(message)
            STDERR.puts "ERROR: #{message}"
          end

          def fatal(message)
            STDERR.puts "FATAL: #{message}"
          end
        end
      end
    end
  end
end
