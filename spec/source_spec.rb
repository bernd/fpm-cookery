require 'spec_helper'
require 'fpm/cookery/source'

describe "Source" do
  describe "#provider?" do
    context "with a provider set" do
      it "returns true" do
        source = FPM::Cookery::Source.new('http://example.com/', :with => :git)

        expect(source.provider?).to eq(true)
      end
    end

    context "without a provider set" do
      it "returns false" do
        source = FPM::Cookery::Source.new('http://example.com/')

        expect(source.provider?).to eq(false)
      end
    end
  end

  describe "#local?" do
    context "with a file:// url" do
      it "returns true" do
        source = FPM::Cookery::Source.new('file:///tmp')

        expect(source.local?).to eq(true)
      end
    end

    context "with no file:// url" do
      it "returns false" do
        source = FPM::Cookery::Source.new('https://www.example.com/')

        expect(source.local?).to eq(false)
      end
    end
  end

  describe "#path" do
    it "returns the url path" do
      source = FPM::Cookery::Source.new('file:///opt/src/foo')

      expect(source.path).to eq('/opt/src/foo')
    end
  end

  context "with a private GitHub URL" do
    it "can handle it" do
      source = FPM::Cookery::Source.new('git@github.com:foo/bar.git')

      expect(source.url).to eq('git@github.com:foo/bar.git')
      expect(source.path).to eq('foo/bar.git')
    end
  end
end
