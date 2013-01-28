require 'fpm/cookery/log/output/null'
require 'cabin' # Via fpm.
require 'json'

module FPM
  module Cookery
    module Log
      @debug = false
      @output = FPM::Cookery::Log::Output::Null.new

      @channel = ::Cabin::Channel.get
      @channel.subscribe(self)
      @channel.level = :debug

      class << self
        def enable_debug(value = true)
          @debug = value
        end

        def output(out)
          @output = out
        end

        def debug(message)
          @output.debug(message) if @debug
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

        def <<(event)
          level = event.fetch(:level, :info).downcase.to_sym

          event.delete(:level)

          data = event.clone

          data.delete(:message)
          data.delete(:timestamp)

          send(level, "[FPM] #{event[:message]} #{data.to_json}")
        end
      end
    end
  end
end
