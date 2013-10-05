require 'stringio'
require 'fpm/cookery/log'
module FPM
  module Cookery
    module Utils
      # 
      module Ruby

        def ruby
          [embedded_ruby,destination_ruby,system_ruby].each do |ruby|
            if ruby.valid?
              FPM::Cookery::Log.info("Using #{ruby.binary}")
              return ruby
            end
          end
        end

        def destination_ruby
          return Environment.new(destination, destination, destdir)
        end

        def system_ruby
          return Environment.new(real, destination, destdir)
        end

        def embedded_ruby
          e = destination.rebase(destination.root / "embedded")
          return Environment.new(e, e, destdir)
        end

        class Environment

          attr :current, :destination, :destdir

          def binary
            (current.bin / 'ruby').to_s
          end

          def valid?
            File.exists?(binary)
          end

          def initialize(current,destination, destdir)
            @current = current
            @destination = destination
            @destdir = destdir
          end

          def fix_gem_binaries!
            Dir.new(destination.bin).each do |file|
              path = (destination.bin / file).to_s
              next if File.directory?(path)
              rd = File.open(path,'r')
              begin
                first_line = rd.gets
                if first_line.include?(destdir.to_s)
                  # rewrite needed
                  first_line.gsub!(destdir.to_s,'')
                  wr = File.open(path, 'w')
                  wr.write(first_line)
                  IO.copy_stream(rd, wr)
                  wr.close
                end
              ensure
                rd.close
              end
            end
          end

          def run(*args)
            cmd = [(current.bin / 'ruby').to_s,*args]
            pid = Process.spawn(env, *cmd, unsetenv_others: true)
            Process.waitpid(pid)
            if $?.exitstatus != 0
              raise "Command failed: #{env.inspect} #{cmd.join(" ")}"
            end
          end

          def gem(*args)
            run('-S','gem',*args)
            fix_gem_binaries!
          end

        private
          def env
            {
              'PATH'     => ENV['PATH'],
              'RUBYLIB'  => default_load_path.map{|p| destdir / p }.join(":"),
              'RUBYPATH' => current.bin.to_s,
              'LD_LIBRARY_PATH' => current.lib.to_s
            }
          end

          def default_load_path
            IO.popen([{'LD_LIBRARY_PATH' => current.lib.to_s},
                     (current.bin / 'ruby').to_s,'--disable=gems','-e','puts $LOAD_PATH.join("\\0")',
                     unsetenv_others: true]) do |io|
              return io.read.chomp.split("\0")
            end
          end

        end

      end
    end
  end
end
