require 'spec_helper'
require 'fpm/cookery/facts'

describe "Facts" do
  before do
    FPM::Cookery::Facts.reset!
  end

  describe "arch" do
    it "returns the current architecture as a symbol" do
      expect(FPM::Cookery::Facts.arch).to be_a(Symbol)
    end

    it "returns a valid architecture" do
      expect(FPM::Cookery::Facts.arch).to_not be_nil
    end
  end

  describe "platform" do
    context "with /etc/os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=ubuntu',
          'VERSION_ID="22.04"',
          'VERSION_CODENAME=jammy'
        ])
      end

      it "detects platform from os-release ID" do
        expect(FPM::Cookery::Facts.platform).to eq(:ubuntu)
      end
    end

    context "with CentOS in /etc/os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID="centos"',
          'VERSION_ID="7"'
        ])
      end

      it "detects CentOS platform" do
        expect(FPM::Cookery::Facts.platform).to eq(:centos)
      end
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'CentOS'
      expect(FPM::Cookery::Facts.platform).to eq(:centos)
    end

    context "when platform detection fails completely" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/debian_version').and_return(false)
        allow(File).to receive(:exist?).with('/etc/redhat-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/alpine-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/arch-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/gentoo-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/SuSE-release').and_return(false)
        stub_const('RUBY_PLATFORM', 'x86_64-linux')
      end

      it "raises PlatformDetectionError" do
        expect { FPM::Cookery::Facts.platform }.to raise_error(FPM::Cookery::PlatformDetectionError)
      end

      it "includes helpful message in error" do
        expect { FPM::Cookery::Facts.platform }.to raise_error(/Unable to detect platform/)
      end

      it "suggests manual override in error message" do
        expect { FPM::Cookery::Facts.platform }.to raise_error(/Set platform manually/)
      end
    end

    context "when platform is set manually before detection" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/debian_version').and_return(false)
        allow(File).to receive(:exist?).with('/etc/redhat-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/alpine-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/arch-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/gentoo-release').and_return(false)
        allow(File).to receive(:exist?).with('/etc/SuSE-release').and_return(false)
        stub_const('RUBY_PLATFORM', 'x86_64-linux')
      end

      it "does not raise error when platform is pre-set" do
        FPM::Cookery::Facts.platform = 'debian'
        expect(FPM::Cookery::Facts.platform).to eq(:debian)
      end
    end
  end

  describe "osrelease" do
    context "with /etc/os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=centos',
          'VERSION_ID="6.5"'
        ])
      end

      it "returns the operating system release version" do
        expect(FPM::Cookery::Facts.osrelease).to eq('6.5')
      end
    end
  end

  describe "osmajorrelease" do
    context "with /etc/os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=centos',
          'VERSION_ID="6.5"'
        ])
      end

      it "returns the operating system major release version" do
        expect(FPM::Cookery::Facts.osmajorrelease).to eq('6')
      end
    end
  end

  describe "osfamily" do
    context "with ID_LIKE in os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=ubuntu',
          'ID_LIKE=debian'
        ])
      end

      it "detects osfamily from ID_LIKE" do
        expect(FPM::Cookery::Facts.osfamily).to eq(:debian)
      end
    end

    context "with RedHat-like in os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=rocky',
          'ID_LIKE="rhel centos fedora"'
        ])
      end

      it "detects osfamily as redhat" do
        expect(FPM::Cookery::Facts.osfamily).to eq(:redhat)
      end
    end

    it "can be set" do
      FPM::Cookery::Facts.osfamily = 'RedHat'
      expect(FPM::Cookery::Facts.osfamily).to eq(:redhat)
    end
  end

  describe "lsbcodename" do
    context "with VERSION_CODENAME in os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=ubuntu',
          'VERSION_CODENAME=trusty'
        ])
      end

      it "returns the codename" do
        expect(FPM::Cookery::Facts.lsbcodename).to eq(:trusty)
      end
    end

    context "with UBUNTU_CODENAME in os-release" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=linuxmint',
          'UBUNTU_CODENAME=focal'
        ])
      end

      it "returns the Ubuntu codename" do
        expect(FPM::Cookery::Facts.lsbcodename).to eq(:focal)
      end
    end

    context "with lsb_release fallback" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          'ID=debian'
        ])
        allow(FPM::Cookery::Facts).to receive(:system).and_return(true)
      end

      it "rejects output longer than 64 characters" do
        long_output = 'a' * 65
        allow(FPM::Cookery::Facts).to receive(:`).with('lsb_release -cs 2>/dev/null').and_return(long_output)
        expect(FPM::Cookery::Facts.lsbcodename).to be_nil
      end

      it "rejects output with invalid characters" do
        allow(FPM::Cookery::Facts).to receive(:`).with('lsb_release -cs 2>/dev/null').and_return("bookworm; rm -rf /")
        expect(FPM::Cookery::Facts.lsbcodename).to be_nil
      end

      it "accepts valid codenames with dots" do
        allow(FPM::Cookery::Facts).to receive(:`).with('lsb_release -cs 2>/dev/null').and_return("n/a")
        expect(FPM::Cookery::Facts.lsbcodename).to be_nil
      end

      it "accepts valid codenames with hyphens and underscores" do
        allow(FPM::Cookery::Facts).to receive(:`).with('lsb_release -cs 2>/dev/null').and_return("test-code_name.1")
        expect(FPM::Cookery::Facts.lsbcodename).to eq(:"test-code_name.1")
      end

      it "returns valid codename from lsb_release" do
        allow(FPM::Cookery::Facts).to receive(:`).with('lsb_release -cs 2>/dev/null').and_return("bookworm\n")
        expect(FPM::Cookery::Facts.lsbcodename).to eq(:bookworm)
      end
    end
  end

  describe "target" do
    describe "with os family RedHat" do
      it "returns rpm" do
        FPM::Cookery::Facts.osfamily = 'RedHat'
        expect(FPM::Cookery::Facts.target).to eq(:rpm)
      end
    end

    describe "with os family Suse" do
      it "returns rpm" do
        FPM::Cookery::Facts.osfamily = 'Suse'
        expect(FPM::Cookery::Facts.target).to eq(:rpm)
      end
    end

    describe "with os family Debian" do
      it "returns deb" do
        FPM::Cookery::Facts.osfamily = 'Debian'
        expect(FPM::Cookery::Facts.target).to eq(:deb)
      end
    end

    describe "with os family Darwin" do
      it "returns osxpkg" do
        FPM::Cookery::Facts.osfamily = 'Darwin'
        expect(FPM::Cookery::Facts.target).to eq(:osxpkg)
      end
    end

    describe "with os family Alpine" do
      it "returns apk" do
        FPM::Cookery::Facts.osfamily = 'Alpine'
        expect(FPM::Cookery::Facts.target).to eq(:apk)
      end
    end

    describe "with an unknown os family" do
      it "returns nil" do
        FPM::Cookery::Facts.osfamily = '___X___'
        expect(FPM::Cookery::Facts.target).to eq(nil)
      end
    end

    it "can be set" do
      FPM::Cookery::Facts.target = 'rpm'
      expect(FPM::Cookery::Facts.target).to eq(:rpm)
    end
  end

  describe "parse_os_release" do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
    end

    it "handles quoted values" do
      allow(File).to receive(:readlines).with('/etc/os-release').and_return([
        'ID="ubuntu"',
        "NAME='Ubuntu'",
        'VERSION_ID="22.04"'
      ])

      expect(FPM::Cookery::Facts.platform).to eq(:ubuntu)
      expect(FPM::Cookery::Facts.osrelease).to eq('22.04')
    end

    it "handles unquoted values" do
      allow(File).to receive(:readlines).with('/etc/os-release').and_return([
        'ID=alpine',
        'VERSION_ID=3.18.0'
      ])

      expect(FPM::Cookery::Facts.platform).to eq(:alpine)
      expect(FPM::Cookery::Facts.osrelease).to eq('3.18.0')
    end

    it "skips comments and empty lines" do
      allow(File).to receive(:readlines).with('/etc/os-release').and_return([
        '# This is a comment',
        '',
        'ID=debian',
        '   ',
        'VERSION_ID="12"'
      ])

      expect(FPM::Cookery::Facts.platform).to eq(:debian)
    end
  end

  describe "platform to osfamily mapping" do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
    end

    {
      'ubuntu' => :debian,
      'debian' => :debian,
      'linuxmint' => :debian,
      'centos' => :redhat,
      'fedora' => :redhat,
      'rocky' => :redhat,
      'almalinux' => :redhat,
      'opensuse' => :suse,
      'alpine' => :alpine,
      'arch' => :archlinux
    }.each do |platform, expected_family|
      it "maps #{platform} to #{expected_family}" do
        allow(File).to receive(:readlines).with('/etc/os-release').and_return([
          "ID=#{platform}"
        ])
        FPM::Cookery::Facts.reset!
        expect(FPM::Cookery::Facts.osfamily).to eq(expected_family)
      end
    end
  end

  describe "detect_redhat_platform" do
    it "returns :redhat when file cannot be read (permission denied)" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_raise(Errno::EACCES)
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:redhat)
    end

    it "returns :redhat when file disappears after exist check (ENOENT)" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_raise(Errno::ENOENT)
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:redhat)
    end

    it "returns :redhat when path is a directory (EISDIR)" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_raise(Errno::EISDIR)
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:redhat)
    end

    it "returns :redhat on IO error" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_raise(IOError)
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:redhat)
    end

    it "detects CentOS from redhat-release content" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_return('CentOS Linux release 7.9')
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:centos)
    end

    it "detects Rocky from redhat-release content" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_return('Rocky Linux release 9.2')
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:rocky)
    end

    it "detects Fedora from redhat-release content" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_return('Fedora release 41')
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:fedora)
    end

    it "returns :redhat for unrecognized content" do
      allow(File).to receive(:read).with('/etc/redhat-release').and_return('Some Unknown Linux')
      expect(FPM::Cookery::Facts.send(:detect_redhat_platform)).to eq(:redhat)
    end
  end

  describe "command_exists?" do
    let(:tmpdir) { Dir.mktmpdir }
    let(:fake_bin) { File.join(tmpdir, 'fake_cmd') }

    before do
      FileUtils.touch(fake_bin)
      FileUtils.chmod(0755, fake_bin)
    end

    after do
      FileUtils.rm_rf(tmpdir)
    end

    it "returns true when command exists in PATH" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PATH').and_return(tmpdir)
      expect(FPM::Cookery::Facts.send(:command_exists?, 'fake_cmd')).to be true
    end

    it "returns false when command does not exist in PATH" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PATH').and_return(tmpdir)
      expect(FPM::Cookery::Facts.send(:command_exists?, 'nonexistent')).to be false
    end

    it "returns false for command names with semicolons" do
      expect(FPM::Cookery::Facts.send(:command_exists?, 'cmd; rm -rf /')).to be false
    end

    it "returns false for command names with pipes" do
      expect(FPM::Cookery::Facts.send(:command_exists?, 'cmd | cat')).to be false
    end

    it "returns false for command names with backticks" do
      expect(FPM::Cookery::Facts.send(:command_exists?, 'cmd`whoami`')).to be false
    end

    it "returns false for command names with path traversal" do
      expect(FPM::Cookery::Facts.send(:command_exists?, '../bin/cmd')).to be false
    end

    it "returns false for command names with absolute paths" do
      expect(FPM::Cookery::Facts.send(:command_exists?, '/usr/bin/cmd')).to be false
    end

    it "returns false when PATH is empty" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PATH').and_return('')
      expect(FPM::Cookery::Facts.send(:command_exists?, 'fake_cmd')).to be false
    end

    it "returns false when PATH is nil" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PATH').and_return(nil)
      expect(FPM::Cookery::Facts.send(:command_exists?, 'fake_cmd')).to be false
    end
  end
end
