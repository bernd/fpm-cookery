require 'spec_helper'
require 'fpm/cookery/source'

describe "Source" do
  describe "#provider?" do
    context "with a provider set" do
      it "returns true" do
        source = FPM::Cookery::Source.new('http://example.com/', :with => :git)

        source.provider?.must_equal true
      end
    end

    context "without a provider set" do
      it "returns false" do
        source = FPM::Cookery::Source.new('http://example.com/')

        source.provider?.must_equal false
      end
    end
  end

  describe "#local?" do
    context "with a file:// url" do
      it "returns true" do
        source = FPM::Cookery::Source.new('file:///tmp')

        source.local?.must_equal true
      end
    end

    context "with no file:// url" do
      it "returns false" do
        source = FPM::Cookery::Source.new('https://www.example.com/')

        source.local?.must_equal false
      end
    end
  end
end
