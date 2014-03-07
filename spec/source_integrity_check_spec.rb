require 'spec_helper'
require 'fpm/cookery/source_integrity_check'
require 'fpm/cookery/recipe'

describe "SourceIntegrityCheck" do
  let(:recipe_class) do
    Class.new(FPM::Cookery::Recipe) {
      source 'http://example.com/foo.tar.gz'
    }
  end

  let(:config) { double('Config').as_null_object }
  let(:recipe) { recipe_class.new(__FILE__, config) }
  let(:check) { FPM::Cookery::SourceIntegrityCheck.new(recipe) }

  before do
    allow(recipe).to receive(:local_path).and_return(fixture_path('test-source-1.0.tar.gz'))
  end

  describe "without any checksum defined" do
    describe "#error?" do
      it "returns true" do
        expect(check.error?).to eq(true)
      end
    end

    describe "#checksum_missing?" do
      it "returns true" do
        expect(check.checksum_missing?).to eq(true)
      end
    end

    it "has checksum_expected set to nil" do
      expect(check.checksum_expected).to eq(nil)
    end

    it "has checksum_actual set to the sha256 checksum" do
      expect(check.checksum_actual).to eq('285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22')
    end

    it "has filename set" do
      expect(check.filename).to eq(fixture_path('test-source-1.0.tar.gz'))
    end

    it "has digest set to nil" do
      expect(check.digest).to eq(:sha256)
    end
  end

  describe "with a correct sha256 checksum defined" do
    describe "#error?" do
      it "returns false" do
        allow(recipe).to receive(:sha256).and_return('285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22')

        expect(check.error?).to eq(false)
      end
    end
  end

  describe "with a wrong sha256 checksum defined" do
    before do
      allow(recipe).to receive(:sha256).and_return('xxxx6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22')
    end

    describe "#error?" do
      it "returns true" do
        expect(check.error?).to eq(true)
      end
    end

    it "has checksum_expected set to the expected checksum" do
      expect(check.checksum_expected).to eq('xxxx6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22')
    end

    it "has checksum_actual set to the actual checksum" do
      expect(check.checksum_actual).to eq('285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22')
    end

    it "has filename set" do
      expect(check.filename).to eq(fixture_path('test-source-1.0.tar.gz'))
    end

    it "has digest set to :sha256" do
      expect(check.digest).to eq(:sha256)
    end
  end

  describe "with a correct sha1 checksum defined" do
    describe "#error?" do
      it "returns false" do
        allow(recipe).to receive(:sha1).and_return('dd4a8575c60f8122c30d21dfeed9f23f64948bf7')

        expect(check.error?).to eq(false)
      end
    end
  end

  describe "with a wrong sha1 checksum defined" do
    before do
      allow(recipe).to receive(:sha1).and_return('xxxx8575c60f8122c30d21dfeed9f23f64948bf7')
    end

    describe "#error?" do
      it "returns true" do
        expect(check.error?).to eq(true)
      end
    end

    it "has checksum_expected set to the expected checksum" do
      expect(check.checksum_expected).to eq('xxxx8575c60f8122c30d21dfeed9f23f64948bf7')
    end

    it "has checksum_actual set to the actual checksum" do
      expect(check.checksum_actual).to eq('dd4a8575c60f8122c30d21dfeed9f23f64948bf7')
    end

    it "has filename set" do
      expect(check.filename).to eq(fixture_path('test-source-1.0.tar.gz'))
    end

    it "has digest set to :sha1" do
      expect(check.digest).to eq(:sha1)
    end
  end

  describe "with a correct md5 checksum defined" do
    describe "#error?" do
      it "returns false" do
        allow(recipe).to receive(:md5).and_return('d8f1330c3d1cec72287b88b2a6c1bc91')

        expect(check.error?).to eq(false)
      end
    end
  end

  describe "with a wrong md5 checksum defined" do
    before do
      allow(recipe).to receive(:md5).and_return('xxxx330c3d1cec72287b88b2a6c1bc91')
    end

    describe "#error?" do
      it "returns true" do
        expect(check.error?).to eq(true)
      end
    end

    it "has checksum_expected set to the expected checksum" do
      expect(check.checksum_expected).to eq('xxxx330c3d1cec72287b88b2a6c1bc91')
    end

    it "has checksum_actual set to the actual checksum" do
      expect(check.checksum_actual).to eq('d8f1330c3d1cec72287b88b2a6c1bc91')
    end

    it "has filename set" do
      expect(check.filename).to eq(fixture_path('test-source-1.0.tar.gz'))
    end

    it "has digest set to :md5" do
      expect(check.digest).to eq(:md5)
    end
  end
end
