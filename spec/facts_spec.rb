require 'spec_helper'
require 'ostruct'
require 'fpm/cookery/facts'

describe "Facts" do
  describe "platform" do
    before do
      Facter.class_eval do
        def self.fact(v)
          v == :operatingsystem ? OpenStruct.new(:value => 'CentOS') : nil
        end
      end
      FPM::Cookery::Facts.reset!
    end

    it "is using Facter to autodetect the platform" do
      FPM::Cookery::Facts.platform.must_equal :centos
    end

    it "can be set" do
      FPM::Cookery::Facts.platform = 'foo'
      FPM::Cookery::Facts.platform.must_equal :foo
    end
  end
end
