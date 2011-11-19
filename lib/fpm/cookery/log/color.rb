module FPM
  module Cookery
    module Log
      class Color
        CODES = {
          :black   => 30,
          :blue    => 34,
          :cyan    => 36,
          :green   => 32,
          :magenta => 35,
          :red     => 31,
          :reset   => 0,
          :white   => 39,
          :yellow  => 33,
        }

        class << self
          def color(name, type = nil)
            tint = CODES[name] || 0

            case type
            when :bold
              escape("1;#{tint}")
            when :underline
              escape("4;#{tint}")
            else
              escape(tint)
            end
          end

          def colorize(string, tint, type = nil)
            "#{color(tint, type)}#{string}#{color(:reset)}"
          end

          def black(string, type = nil)   colorize(string, :black, type)   end
          def blue(string, type = nil)    colorize(string, :blue, type)    end
          def cyan(string, type = nil)    colorize(string, :cyan, type)    end
          def green(string, type = nil)   colorize(string, :green, type)   end
          def magenta(string, type = nil) colorize(string, :magenta, type) end
          def red(string, type = nil)     colorize(string, :red, type)     end
          def reset(string, type = nil)   colorize(string, :reset, type)   end
          def white(string, type = nil)   colorize(string, :white, type)   end
          def yellow(string, type = nil)  colorize(string, :yellow, type)  end

          private
          def escape(num)
            "\033[#{num}m" if $stdout.tty?
          end
        end
      end
    end
  end
end
