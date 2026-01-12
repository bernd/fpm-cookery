require 'rbconfig'

module FPM
  module Cookery
    class PlatformDetectionError < StandardError; end

    class Facts
      class << self
        def arch
          @arch ||= detect_arch
        end

        def platform
          @platform ||= detect_platform
        end

        def platform=(value)
          @platform = value.downcase.to_sym
        end

        def osrelease
          @osrelease ||= os_release_data['VERSION_ID']
        end

        def osmajorrelease
          @osmajorrelease ||= osrelease&.split('.')&.first
        end

        def osfamily
          @osfamily ||= detect_osfamily
        end

        def osfamily=(value)
          @osfamily = value.downcase.to_sym
        end

        def lsbcodename
          @lsbcodename ||= detect_lsbcodename
        end

        def target
          @target ||= case osfamily
                      when :redhat, :suse then :rpm
                      when :debian        then :deb
                      when :darwin        then :osxpkg
                      when :alpine        then :apk
                      when :archlinux     then :pacman
                      end
        end

        def target=(value)
          @target = value.to_sym
        end

        def reset!
          instance_variables.each { |v| instance_variable_set(v, nil) }
        end

        private

        def os_release_data
          @os_release_data ||= parse_os_release
        end

        def parse_os_release
          path = '/etc/os-release'
          return {} unless File.exist?(path)

          File.readlines(path).each_with_object({}) do |line, hash|
            line = line.strip
            next if line.empty? || line.start_with?('#')
            key, value = line.split('=', 2)
            next unless key && value
            # Remove surrounding quotes
            hash[key] = value.gsub(/\A["']|["']\z/, '')
          end
        end

        def detect_arch
          arch = RbConfig::CONFIG['host_cpu']&.downcase
          return nil unless arch
          arch.to_sym
        end

        def detect_platform
          # Try /etc/os-release first (freedesktop.org standard)
          id = os_release_data['ID']&.downcase
          return id.to_sym if id && !id.empty?

          # Fallback detection for older systems
          result = case
          when File.exist?('/etc/debian_version')
            :debian
          when File.exist?('/etc/redhat-release')
            detect_redhat_platform
          when File.exist?('/etc/alpine-release')
            :alpine
          when File.exist?('/etc/arch-release')
            :arch
          when File.exist?('/etc/gentoo-release')
            :gentoo
          when File.exist?('/etc/SuSE-release')
            :suse
          when RUBY_PLATFORM.include?('darwin')
            :darwin
          end

          return result if result

          raise PlatformDetectionError, <<~MSG.strip
            Unable to detect platform. Checked:
            - /etc/os-release (ID field)
            - /etc/debian_version, /etc/redhat-release, /etc/alpine-release
            - /etc/arch-release, /etc/gentoo-release, /etc/SuSE-release
            - RUBY_PLATFORM for darwin

            Set platform manually: FPM::Cookery::Facts.platform = 'debian'
            Or use --platform option with fpm-cook command.
          MSG
        end

        def detect_redhat_platform
          content = File.read('/etc/redhat-release').downcase
          case content
          when /centos/ then :centos
          when /fedora/ then :fedora
          when /rocky/ then :rocky
          when /alma/ then :almalinux
          when /oracle/ then :oracle
          when /scientific/ then :scientific
          else :redhat
          end
        rescue
          :redhat
        end

        def detect_osfamily
          # Try ID_LIKE from os-release first, then fall back to platform mapping
          id_like = os_release_data['ID_LIKE']&.downcase&.split&.first&.to_sym
          source = id_like || platform

          # Normalize to canonical family names
          case source
          when :ubuntu, :debian, :linuxmint, :pop, :elementary, :raspbian, :kali
            :debian
          when :centos, :rhel, :redhat, :fedora, :rocky, :almalinux, :oracle, :amzn, :scientific, :cloudlinux
            :redhat
          when :opensuse, :sles, :suse
            :suse
          when :alpine
            :alpine
          when :arch, :manjaro
            :archlinux
          when :gentoo
            :gentoo
          when :darwin
            :darwin
          end
        end

        def detect_lsbcodename
          # Try os-release first
          codename = os_release_data['VERSION_CODENAME']
          return codename.downcase.to_sym if codename && !codename.empty?

          # Try Ubuntu-specific field
          codename = os_release_data['UBUNTU_CODENAME']
          return codename.downcase.to_sym if codename && !codename.empty?

          # Fallback to lsb_release command
          lsb_release_codename
        end

        def lsb_release_codename
          return nil unless command_exists?('lsb_release')
          output = `lsb_release -cs 2>/dev/null`.strip
          return nil if output.empty?
          # Validate output before creating symbol to prevent symbol table exhaustion
          # Codenames are usually short (e.g., "bookworm", "jammy") and alphanumeric with hyphens
          return nil if output.length > 64
          return nil unless output.match?(/\A[a-zA-Z0-9._-]+\z/)
          output.downcase.to_sym
        rescue Errno::ENOENT, IOError
          nil
        end

        def command_exists?(cmd)
          # Validate command name - must be simple name, no paths or shell metacharacters
          return false unless cmd.match?(/\A[a-zA-Z0-9._-]+\z/)

          ENV['PATH'].to_s.split(File::PATH_SEPARATOR).any? do |dir|
            path = File.join(dir, cmd)
            File.executable?(path) && File.file?(path)
          end
        end
      end
    end
  end
end
