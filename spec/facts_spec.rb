require 'spec_helper'
require 'ostruct'
require 'fpm/cookery/facts'

describe "Facts" do
  describe "operatingsystem" do
    before do
      Facter.class_eval do
        def self.fact(v)
          v == :operatingsystem ? OpenStruct.new(:value => :centos) : nil
        end
      end
      FPM::Cookery::Facts.reset!
    end

    it "is using Facter to autodetect the platform" do
      FPM::Cookery::Facts.operatingsystem.must_equal :centos
    end

    it "can be set" do
      FPM::Cookery::Facts.operatingsystem = :foo
      FPM::Cookery::Facts.operatingsystem.must_equal :foo
    end
  end
end
