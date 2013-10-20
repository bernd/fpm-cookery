require 'stringio'
require 'fpm/cookery/log'
module FPM
  module Cookery
    module Utils
      # A utils module that helps working with embedded ruby 
      #
      module Ruby

        # The "current" ruby, depending on the situation.
        #
        # @return [Environment]
        def ruby
          [embedded_ruby,destination_ruby,system_ruby].each do |ruby|
            if ruby.valid?
              FPM::Cookery::Log.info("Using #{ruby.binary}")
              return ruby
            end
          end
        end

        # This is the ruby in the destination directory.
        #
        # @return [Environment]
        def destination_ruby
          return Environment.new(destination, destination, destdir)
        end

        # This is the ruby which is currently installed in the system 
        # (/usr/bin/ruby).
        #
        # @return [Environment]
        def system_ruby
          return Environment.new(real, destination, destdir)
        end

        # This is the ruby embedded in the destination directory. Only pointful 
        # for omnibus packages.
        #
        # @return [Environment]
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

          # Fixes all gem binaries in the bin path.
          # 
          # Rubygems installs the binaries with a wrong shebang.
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

          # Run ruby with the given arguments. See the ruby documentation for options
          #
          # @example
          #   # inside a recipe
          #   ruby.run('-e','puts "ping"')
          #   # outputs ping
          #
          def run(*args)
            cmd = [(current.bin / 'ruby').to_s,*args]
            pid = Process.spawn(env, *cmd, unsetenv_others: true)
            Process.waitpid(pid)
            if $?.exitstatus != 0
              raise "Command failed: #{env.inspect} #{cmd.join(" ")}"
            end
          end

          # Run a gem command with the given arguments.
          #
          # @example install a gem
          #   # inside a recipe
          #   ruby.gem('install','bundler')
          #
          def gem(*args)
            begin
              run('-S','gem',*args)
            ensure
              fix_gem_binaries!
            end
          end

        private
          def env
            env = {
              'PATH'     => ENV['PATH'],
              'RUBYLIB'  => default_load_path.map{|p| destdir / p }.join(":"),
              'RUBYPATH' => current.bin.to_s,
              'LD_LIBRARY_PATH' => current.lib.to_s
            }
            if destination != current
              env['GEM_HOME'] = (destdir / gem_dir).to_s
            end
            return env
          end

          def gem_dir
            IO.popen([{'LD_LIBRARY_PATH' => current.lib.to_s, 'RUBYLIB' => default_load_path.map{|p| destdir / p }.join(":") },
                     (current.bin / 'ruby').to_s,'-e','puts Gem.dir',
                     unsetenv_others: true]) do |io|
              return io.read.chomp
            end
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
