require 'spec_helper'
require 'fpm/cookery/dependency_inspector'

describe FPM::Cookery::DependencyInspector do
  before do
    FPM::Cookery::Facts.reset!
  end

  describe '.package_suitable?' do
    it 'returns true for simple package names' do
      expect(described_class.package_suitable?('curl')).to be true
    end

    it 'returns false for "or" style dependencies' do
      expect(described_class.package_suitable?('pkg1 | pkg2')).to be false
    end

    it 'returns false for >= version constraints' do
      expect(described_class.package_suitable?('pkg >= 1.0')).to be false
    end

    it 'returns false for <= version constraints' do
      expect(described_class.package_suitable?('pkg <= 1.0')).to be false
    end

    it 'returns false for << version constraints' do
      expect(described_class.package_suitable?('pkg << 1.0')).to be false
    end

    it 'returns false for >> version constraints' do
      expect(described_class.package_suitable?('pkg >> 1.0')).to be false
    end

    it 'returns false for < version constraints' do
      expect(described_class.package_suitable?('pkg < 1.0')).to be false
    end

    it 'returns false for > version constraints' do
      expect(described_class.package_suitable?('pkg > 1.0')).to be false
    end
  end

  describe '.package_installed?' do
    context 'on debian family' do
      before do
        FPM::Cookery::Facts.osfamily = 'debian'
      end

      it 'uses dpkg-query to check package status' do
        expect(described_class).to receive(:system).with(
          "dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -q 'install ok installed'"
        ).and_return(true)

        expect(described_class.package_installed?('curl')).to be true
      end

      it 'returns false when package is not installed' do
        expect(described_class).to receive(:system).with(
          "dpkg-query -W -f='${Status}' nonexistent 2>/dev/null | grep -q 'install ok installed'"
        ).and_return(false)

        expect(described_class.package_installed?('nonexistent')).to be false
      end
    end

    context 'on redhat family' do
      before do
        FPM::Cookery::Facts.osfamily = 'redhat'
      end

      it 'uses rpm to check package status' do
        expect(described_class).to receive(:system).with(
          'rpm -q curl >/dev/null 2>&1'
        ).and_return(true)

        expect(described_class.package_installed?('curl')).to be true
      end
    end

    context 'on alpine family' do
      before do
        FPM::Cookery::Facts.osfamily = 'alpine'
      end

      it 'uses apk to check package status' do
        expect(described_class).to receive(:system).with(
          'apk info -e curl >/dev/null 2>&1'
        ).and_return(true)

        expect(described_class.package_installed?('curl')).to be true
      end
    end

    context 'on suse family' do
      before do
        FPM::Cookery::Facts.osfamily = 'suse'
      end

      it 'uses rpm to check package status' do
        expect(described_class).to receive(:system).with(
          'rpm -q curl >/dev/null 2>&1'
        ).and_return(true)

        expect(described_class.package_installed?('curl')).to be true
      end
    end

    context 'on archlinux family' do
      before do
        FPM::Cookery::Facts.osfamily = 'archlinux'
      end

      it 'uses pacman to check package status' do
        expect(described_class).to receive(:system).with(
          'pacman -Q curl >/dev/null 2>&1'
        ).and_return(true)

        expect(described_class.package_installed?('curl')).to be true
      end
    end

    context 'on unsupported platform' do
      before do
        FPM::Cookery::Facts.osfamily = 'unknown'
        described_class.instance_variable_set(:@unsupported_platform_warned, false)
      end

      it 'returns true and logs warning' do
        expect(FPM::Cookery::Log).to receive(:warn).with(/Unsupported platform.*unknown/)
        expect(described_class.package_installed?('curl')).to be true
      end

      it 'only warns once for multiple packages' do
        expect(FPM::Cookery::Log).to receive(:warn).once
        described_class.package_installed?('curl')
        described_class.package_installed?('wget')
      end
    end

    context 'with unsuitable package' do
      before do
        FPM::Cookery::Facts.osfamily = 'debian'
      end

      it 'returns true for "or" style deps without checking' do
        expect(described_class).not_to receive(:system)
        expect(described_class.package_installed?('pkg1 | pkg2')).to be true
      end

      it 'returns true for version constraints without checking' do
        expect(described_class).not_to receive(:system)
        expect(described_class.package_installed?('pkg >= 1.0')).to be true
      end
    end
  end

  describe '.missing_packages' do
    before do
      FPM::Cookery::Facts.osfamily = 'debian'
    end

    it 'returns packages that are not installed' do
      allow(described_class).to receive(:system).and_return(false)

      result = described_class.missing_packages(['pkg1', 'pkg2'])
      expect(result).to eq(['pkg1', 'pkg2'])
    end

    it 'excludes packages that are installed' do
      allow(described_class).to receive(:system).with(
        "dpkg-query -W -f='${Status}' installed 2>/dev/null | grep -q 'install ok installed'"
      ).and_return(true)
      allow(described_class).to receive(:system).with(
        "dpkg-query -W -f='${Status}' missing 2>/dev/null | grep -q 'install ok installed'"
      ).and_return(false)

      result = described_class.missing_packages(['installed', 'missing'])
      expect(result).to eq(['missing'])
    end

    it 'handles nested arrays' do
      allow(described_class).to receive(:system).and_return(false)

      result = described_class.missing_packages([['pkg1'], ['pkg2']])
      expect(result).to eq(['pkg1', 'pkg2'])
    end
  end

  describe '.install_package' do
    context 'on debian family' do
      before do
        FPM::Cookery::Facts.osfamily = 'debian'
      end

      it 'uses apt-get to install package' do
        expect(described_class).to receive(:system).with(
          'apt-get install -y curl'
        ).and_return(true)

        described_class.install_package('curl')
      end

      it 'exits on failure' do
        expect(described_class).to receive(:system).with(
          'apt-get install -y broken'
        ).and_return(false)

        expect { described_class.install_package('broken') }.to raise_error(SystemExit)
      end
    end

    context 'on redhat family' do
      before do
        FPM::Cookery::Facts.osfamily = 'redhat'
      end

      it 'uses yum to install package' do
        expect(described_class).to receive(:system).with(
          'yum install -y curl'
        ).and_return(true)

        described_class.install_package('curl')
      end
    end

    context 'on alpine family' do
      before do
        FPM::Cookery::Facts.osfamily = 'alpine'
      end

      it 'uses apk to install package' do
        expect(described_class).to receive(:system).with(
          'apk add curl'
        ).and_return(true)

        described_class.install_package('curl')
      end
    end

    context 'on suse family' do
      before do
        FPM::Cookery::Facts.osfamily = 'suse'
      end

      it 'uses zypper to install package' do
        expect(described_class).to receive(:system).with(
          'zypper install -y curl'
        ).and_return(true)

        described_class.install_package('curl')
      end
    end

    context 'on archlinux family' do
      before do
        FPM::Cookery::Facts.osfamily = 'archlinux'
      end

      it 'uses pacman to install package' do
        expect(described_class).to receive(:system).with(
          'pacman -S --noconfirm curl'
        ).and_return(true)

        described_class.install_package('curl')
      end
    end

    context 'on unsupported platform' do
      before do
        FPM::Cookery::Facts.osfamily = 'unknown'
      end

      it 'exits with error' do
        expect { described_class.install_package('curl') }.to raise_error(SystemExit)
      end
    end
  end

  describe '.verify!' do
    before do
      FPM::Cookery::Facts.osfamily = 'debian'
    end

    context 'when all packages are installed' do
      it 'logs success message' do
        allow(described_class).to receive(:system).and_return(true)

        described_class.verify!(['dep1'], ['build_dep1'])
      end
    end

    context 'when packages are missing and not root' do
      it 'exits with error' do
        allow(described_class).to receive(:system).and_return(false)
        allow(Process).to receive(:euid).and_return(1000)

        expect { described_class.verify!(['missing'], []) }.to raise_error(SystemExit)
      end
    end

    context 'on unsupported platform' do
      before do
        FPM::Cookery::Facts.osfamily = 'unknown'
      end

      it 'logs warning and returns without checking' do
        described_class.verify!(['dep1'], ['build_dep1'])
      end
    end
  end

  describe 'shell escaping' do
    before do
      FPM::Cookery::Facts.osfamily = 'debian'
    end

    it 'escapes package names with special characters' do
      expect(described_class).to receive(:system).with(
        "dpkg-query -W -f='${Status}' pkg\\'name 2>/dev/null | grep -q 'install ok installed'"
      ).and_return(true)

      described_class.package_installed?("pkg'name")
    end
  end

  describe 'package database update' do
    before do
      described_class.instance_variable_set(:@package_db_updated, false)
    end

    context 'on debian family' do
      before do
        FPM::Cookery::Facts.osfamily = 'debian'
      end

      it 'runs apt-get update when root' do
        allow(Process).to receive(:euid).and_return(0)
        allow(described_class).to receive(:system).with(anything).and_return(true)

        expect(described_class).to receive(:system).with('apt-get update -qq').and_return(true)

        described_class.verify!([], ['build-essential'])
      end

      it 'does not run update when not root' do
        allow(Process).to receive(:euid).and_return(1000)
        allow(described_class).to receive(:system).with(/dpkg-query/).and_return(true)

        expect(described_class).not_to receive(:system).with('apt-get update -qq')

        described_class.verify!([], [])
      end
    end

    context 'on redhat family' do
      before do
        FPM::Cookery::Facts.osfamily = 'redhat'
      end

      it 'runs yum makecache when root' do
        allow(Process).to receive(:euid).and_return(0)
        allow(described_class).to receive(:system).with(anything).and_return(true)

        expect(described_class).to receive(:system).with('yum makecache -q').and_return(true)

        described_class.verify!([], [])
      end
    end

    context 'on alpine family' do
      before do
        FPM::Cookery::Facts.osfamily = 'alpine'
      end

      it 'runs apk update when root' do
        allow(Process).to receive(:euid).and_return(0)
        allow(described_class).to receive(:system).with(anything).and_return(true)

        expect(described_class).to receive(:system).with('apk update -q').and_return(true)

        described_class.verify!([], [])
      end
    end

    context 'on suse family' do
      before do
        FPM::Cookery::Facts.osfamily = 'suse'
      end

      it 'runs zypper refresh when root' do
        allow(Process).to receive(:euid).and_return(0)
        allow(described_class).to receive(:system).with(anything).and_return(true)

        expect(described_class).to receive(:system).with('zypper refresh -q').and_return(true)

        described_class.verify!([], [])
      end
    end

    context 'on archlinux family' do
      before do
        FPM::Cookery::Facts.osfamily = 'archlinux'
      end

      it 'runs pacman -Sy when root' do
        allow(Process).to receive(:euid).and_return(0)
        allow(described_class).to receive(:system).with(anything).and_return(true)

        expect(described_class).to receive(:system).with('pacman -Sy --noconfirm >/dev/null 2>&1').and_return(true)

        described_class.verify!([], [])
      end
    end

    context 'runs only once' do
      before do
        FPM::Cookery::Facts.osfamily = 'debian'
        allow(Process).to receive(:euid).and_return(0)
      end

      it 'only updates package database once across multiple verify! calls' do
        allow(described_class).to receive(:system).with(/dpkg-query/).and_return(true)

        expect(described_class).to receive(:system).with('apt-get update -qq').once.and_return(true)

        described_class.verify!([], [])
        described_class.verify!([], ['another-package'])
      end
    end

    context 'on unsupported platform' do
      before do
        FPM::Cookery::Facts.osfamily = 'unknown'
      end

      it 'does not attempt to update' do
        expect(described_class).not_to receive(:system).with(/update/)

        described_class.verify!([], [])
      end
    end
  end
end
