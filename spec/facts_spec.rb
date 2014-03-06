require 'spec_helper'
require 'ostruct'
require 'fpm/cookery/facts'

describe "Facts" do
  before do
    FPM::Cookery::Facts.reset!
  end

  describe "arch" do
    before do
      Facter.class_eval do
        def self.fact(v)
          v == :architecture ? OpenStruct.new(:value => 'x86_64') : nil
        end
      end
    end

    it "is returns the current platform" do
      expect(FPM::Cookery::Facts.arch).to eq(:x86_64)
    end
  end

  describe "platform" do
    before do
      Facter.class_eval do
        def self.fact(v)
          v == :operatingsystem ? OpenStruct.new(:value => 'CentOS') : nil
        end
      end
    end

    it "is using Facter to autodetect the platform" do
      expect(FPM::Cookery::Facts.platform).to eq(:centos)
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'CentOS'
      expect(FPM::Cookery::Facts.platform).to eq(:centos)
    end
  end

  describe "target" do
    describe "with platform CentOS" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'CentOS'
        expect(FPM::Cookery::Facts.target).to eq(:rpm)
      end
    end

    describe "with platform RedHat" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'RedHat'
        expect(FPM::Cookery::Facts.target).to eq(:rpm)
      end
    end

    describe "with platform Fedora" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Fedora'
        expect(FPM::Cookery::Facts.target).to eq(:rpm)
      end
    end

    describe "with platform Debian" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Debian'
        expect(FPM::Cookery::Facts.target).to eq(:deb)
      end
    end

    describe "with platform Ubuntu" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Ubuntu'
        expect(FPM::Cookery::Facts.target).to eq(:deb)
      end
    end

    describe "with platform Darwin" do
      it "returns osxpkg" do
        FPM::Cookery::Facts.platform = 'Darwin'
        expect(FPM::Cookery::Facts.target).to eq(:osxpkg)
      end
    end

    describe "with an unknown platform" do
      it "returns nil" do
        FPM::Cookery::Facts.platform = '___X___'
        expect(FPM::Cookery::Facts.target).to eq(nil)
      end
    end

    it "can be set" do
      FPM::Cookery::Facts.target = 'rpm'
      expect(FPM::Cookery::Facts.target).to eq(:rpm)
    end
  end
end
