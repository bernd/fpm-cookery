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

  describe "#path" do
    it "returns the url path" do
      source = FPM::Cookery::Source.new('file:///opt/src/foo')

      source.path.must_equal '/opt/src/foo'
    end
  end

  context "with a private GitHub URL" do
    it "can handle it" do
      source = FPM::Cookery::Source.new('git@github.com:foo/bar.git')

      source.url.must_equal 'git@github.com:foo/bar.git'
      source.path.must_equal 'foo/bar.git'
    end
  end
end
