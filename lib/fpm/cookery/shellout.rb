require 'fpm/cookery/log'
require 'systemu'

module FPM
  module Cookery
    class Shellout
      class CommandFailed < StandardError
        attr_reader :output

        def initialize(message, output)
          super(message)
          @output = output
        end
      end

      def self.git_config_get(key)
        new('git config --get %s', key).run.chomp
      end

      def initialize(command, *args)
        @command = command.to_s % args
      end

      def run
        status, stdout, stderr = systemu(@command)

        if status.success?
          stdout
        else
          raise CommandFailed.new("Shellout command failed: #{@command}", stderr)
        end
      end
    end
  end
end
