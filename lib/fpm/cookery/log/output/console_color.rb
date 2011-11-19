require 'fpm/cookery/log/color'

module FPM
  module Cookery
    module Log
      module Output
        class ConsoleColor
          def debug(message)
            puts "#{Color.cyan('DEBUG:')} #{message}"
          end

          def info(message)
            puts "#{Color.blue('===>')} #{message}"
          end

          def puts(message)
            Kernel.puts "#{message}"
          end

          def warn(message)
            STDERR.puts "#{Color.yellow('WARNING:')} #{message}"
          end

          def error(message)
            STDERR.puts "#{Color.red('ERROR:')} #{message}"
          end

          def fatal(message)
            STDERR.puts "#{Color.red('FATAL:', :bold)} #{message}"
          end
        end
      end
    end
  end
end
