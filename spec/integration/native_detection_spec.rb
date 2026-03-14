require 'spec_helper'
require 'fpm/cookery/facts'
require 'fpm/cookery/dependency_inspector'

# Integration tests that verify native OS detection works on real systems.
# These tests do NOT mock the file system or shell commands.
# Run with: bundle exec rspec spec/integration/native_detection_spec.rb

RSpec.describe 'Native OS Detection (Integration)', :integration do
  before(:all) do
    # Reset any cached values
    FPM::Cookery::Facts.reset!
  end

  describe FPM::Cookery::Facts do
    describe '.platform' do
      it 'detects a known platform' do
        platform = FPM::Cookery::Facts.platform
        expect(platform).not_to be_nil
        expect(platform.to_s).not_to be_empty
      end

      it 'returns a symbol' do
        expect(FPM::Cookery::Facts.platform).to be_a(Symbol)
      end
    end

    describe '.arch' do
      it 'detects architecture' do
        arch = FPM::Cookery::Facts.arch
        expect(arch).not_to be_nil
        expect(arch.to_s).to match(/x86_64|amd64|aarch64|arm64|arm|i[3-6]86/)
      end
    end

    describe '.osrelease' do
      it 'detects OS release version' do
        release = FPM::Cookery::Facts.osrelease
        # Some systems may not have a version (e.g., rolling releases)
        # but it should at least return something or nil
        expect(release).to satisfy { |r| r.nil? || r.is_a?(String) }
      end
    end

    describe '.osfamily' do
      it 'detects a known OS family' do
        osfamily = FPM::Cookery::Facts.osfamily
        expect(osfamily).not_to be_nil
        known_families = [:debian, :redhat, :suse, :alpine, :archlinux, :darwin]
        expect(known_families).to include(osfamily)
      end
    end

    describe '.lsbcodename' do
      it 'returns a string, symbol, or nil' do
        codename = FPM::Cookery::Facts.lsbcodename
        expect(codename).to satisfy { |c| c.nil? || c.is_a?(String) || c.is_a?(Symbol) }
      end
    end

    describe '.target' do
      it 'detects package target format' do
        target = FPM::Cookery::Facts.target
        expect(target).not_to be_nil
        known_targets = [:deb, :rpm, :apk, :pacman, :osxpkg]
        expect(known_targets).to include(target)
      end
    end
  end

  describe FPM::Cookery::DependencyInspector do
    describe '.verify!' do
      it 'does not raise for empty dependency list' do
        expect {
          FPM::Cookery::DependencyInspector.verify!([], [])
        }.not_to raise_error
      end

      it 'skips versioned dependencies gracefully' do
        # Versioned deps should be skipped, not cause errors
        expect {
          FPM::Cookery::DependencyInspector.verify!(['fake-package (>= 1.0)'], [])
        }.not_to raise_error
      end
    end

    describe '.package_installed?' do
      it 'returns false for non-existent package' do
        # Use a package name that definitely doesn't exist
        result = FPM::Cookery::DependencyInspector.package_installed?('this-package-definitely-does-not-exist-12345')
        expect(result).to be false
      end

      it 'returns true for a common installed package' do
        # Test with packages likely to be installed in containers
        common_packages = case FPM::Cookery::Facts.osfamily
        when :debian
          ['coreutils', 'bash']
        when :redhat
          ['coreutils', 'bash']
        when :alpine
          ['busybox', 'musl']
        else
          ['bash']
        end

        installed = common_packages.any? do |pkg|
          FPM::Cookery::DependencyInspector.package_installed?(pkg)
        end

        expect(installed).to be true
      end
    end
  end
end
