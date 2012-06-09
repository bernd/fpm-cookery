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
      FPM::Cookery::Facts.arch.must_equal :x86_64
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
      FPM::Cookery::Facts.platform.must_equal :centos
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'CentOS'
      FPM::Cookery::Facts.platform.must_equal :centos
    end
  end

  describe "target" do
    describe "with platform CentOS" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'CentOS'
        FPM::Cookery::Facts.target.must_equal :rpm
      end
    end

    describe "with platform RedHat" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'RedHat'
        FPM::Cookery::Facts.target.must_equal :rpm
      end
    end

    describe "with platform Fedora" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Fedora'
        FPM::Cookery::Facts.target.must_equal :rpm
      end
    end

    describe "with platform Debian" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Debian'
        FPM::Cookery::Facts.target.must_equal :deb
      end
    end

    describe "with platform Ubuntu" do
      it "returns rpm" do
        FPM::Cookery::Facts.platform = 'Ubuntu'
        FPM::Cookery::Facts.target.must_equal :deb
      end
    end

    describe "with an unknown platform" do
      it "returns nil" do
        FPM::Cookery::Facts.platform = '___X___'
        FPM::Cookery::Facts.target.must_equal nil
      end
    end

    it "can be set" do
      FPM::Cookery::Facts.target = 'rpm'
      FPM::Cookery::Facts.target.must_equal :rpm
    end
  end
end
