require 'spec_helper'
require 'fpm/cookery/facts'

shared_context "mock facts" do |facts = {}|
  before do
    facts.each_pair do |k, v|
      allow(Facter).to receive(:value).with(k).and_return(v)
    end
  end
end

describe "Facts" do
  before do
    FPM::Cookery::Facts.reset!
  end

  describe "arch" do
    include_context "mock facts", { :architecture => 'x86_64' }

    it "returns the current architecture" do
      expect(FPM::Cookery::Facts.arch).to eq(:x86_64)
    end
  end

  describe "lsbcodename" do
    context "where lsbcodename is present" do
      include_context "mock facts", { :lsbcodename => 'trusty' }

      it "returns the current platforms codename" do
        expect(FPM::Cookery::Facts.lsbcodename).to eq :trusty
      end
    end

    context "where lsbcodename is not present but lsbdistcodename is" do
      include_context "mock facts", { :lsbcodename => nil, :lsbdistcodename => 'trusty' }

      it "returns nil" do
        expect(FPM::Cookery::Facts.lsbcodename).to eq :trusty
      end
    end
  end

  describe "platform" do
    include_context "mock facts", { :operatingsystem => 'CentOS' }

    it "is using Facter to autodetect the platform" do
      expect(FPM::Cookery::Facts.platform).to eq(:centos)
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'CentOS'
      expect(FPM::Cookery::Facts.platform).to eq(:centos)
    end
  end

  describe "osrelease" do
    include_context "mock facts", { :operatingsystemrelease => '6.5' }

    it "returns the operating system release version" do
      expect(FPM::Cookery::Facts.osrelease).to eq('6.5')
    end
  end

  describe "osmajorrelease" do
    include_context "mock facts", { :operatingsystemmajrelease => '6' }

    it "returns the operating system major release version" do
      expect(FPM::Cookery::Facts.osmajorrelease).to eq('6')
    end
  end

  describe "osfamily" do
    include_context "mock facts", { :osfamily => 'RedHat' }

    it "is using Facter to autodetect the osfamily" do
      expect(FPM::Cookery::Facts.osfamily).to eq(:redhat)
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'RedHat'
      expect(FPM::Cookery::Facts.osfamily).to eq(:redhat)
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
end
