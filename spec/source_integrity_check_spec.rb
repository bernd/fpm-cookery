require 'spec_helper'
require 'fpm/cookery/source_integrity_check'
require 'fpm/cookery/recipe'

class TestRecipe < FPM::Cookery::Recipe
  source 'http://example.com/foo.tar.gz'
end

describe "SourceIntegrityCheck" do
  let(:recipe) { TestRecipe.new(__FILE__) }
  let(:check) { FPM::Cookery::SourceIntegrityCheck.new(recipe) }

  before do
    recipe.source_handler.instance_eval do
      def local_path
        fixture_path('test-source-1.0.tar.gz')
      end
    end
  end

  describe "without any checksum defined" do
    describe "#error?" do
      it "returns true" do
        check.error?.must_equal true
      end
    end

    describe "#checksum_missing?" do
      it "returns true" do
        check.checksum_missing?.must_equal true
      end
    end

    it "has checksum_expected set to nil" do
      check.checksum_expected.must_equal nil
    end

    it "has checksum_actual set to the sha256 checksum" do
      check.checksum_actual.must_equal '285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22'
    end

    it "has filename set" do
      check.filename.must_equal fixture_path('test-source-1.0.tar.gz')
    end

    it "has digest set to nil" do
      check.digest.must_equal :sha256
    end
  end

  describe "with a correct sha256 checksum defined" do
    describe "#error?" do
      it "returns false" do
        def recipe.sha256
          '285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22'
        end

        check.error?.must_equal false
      end
    end
  end

  describe "with a wrong sha256 checksum defined" do
    before do
      def recipe.sha256
        'xxxx6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22'
      end
    end

    describe "#error?" do
      it "returns true" do
        check.error?.must_equal true
      end
    end

    it "has checksum_expected set to the expected checksum" do
      check.checksum_expected.must_equal 'xxxx6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22'
    end

    it "has checksum_actual set to the actual checksum" do
      check.checksum_actual.must_equal '285a6b8098ecc9040ece8f621e37c20edba39545c5d195c4894f410ed9d44b22'
    end

    it "has filename set" do
      check.filename.must_equal fixture_path('test-source-1.0.tar.gz')
    end

    it "has digest set to :sha256" do
      check.digest.must_equal :sha256
    end
  end

  describe "with a correct sha1 checksum defined" do
    describe "#error?" do
      it "returns false" do
        def recipe.sha1
          'dd4a8575c60f8122c30d21dfeed9f23f64948bf7'
        end

        check.error?.must_equal false
      end
    end
  end

  describe "with a wrong sha1 checksum defined" do
    before do
      def recipe.sha1
        'xxxx8575c60f8122c30d21dfeed9f23f64948bf7'
      end
    end

    describe "#error?" do
      it "returns true" do
        check.error?.must_equal true
      end
    end

    it "has checksum_expected set to the expected checksum" do
      check.checksum_expected.must_equal 'xxxx8575c60f8122c30d21dfeed9f23f64948bf7'
    end

    it "has checksum_actual set to the actual checksum" do
      check.checksum_actual.must_equal 'dd4a8575c60f8122c30d21dfeed9f23f64948bf7'
    end

    it "has filename set" do
      check.filename.must_equal fixture_path('test-source-1.0.tar.gz')
    end

    it "has digest set to :sha1" do
      check.digest.must_equal :sha1
    end
  end

  describe "with a correct md5 checksum defined" do
    describe "#error?" do
      it "returns false" do
        def recipe.md5
          'd8f1330c3d1cec72287b88b2a6c1bc91'
        end

        check.error?.must_equal false
      end
    end
  end

  describe "with a wrong md5 checksum defined" do
    before do
      def recipe.md5
        'xxxx330c3d1cec72287b88b2a6c1bc91'
      end
    end

    describe "#error?" do
      it "returns true" do
        check.error?.must_equal true
      end
    end

    it "has checksum_expected set to the expected checksum" do
      check.checksum_expected.must_equal 'xxxx330c3d1cec72287b88b2a6c1bc91'
    end

    it "has checksum_actual set to the actual checksum" do
      check.checksum_actual.must_equal 'd8f1330c3d1cec72287b88b2a6c1bc91'
    end

    it "has filename set" do
      check.filename.must_equal fixture_path('test-source-1.0.tar.gz')
    end

    it "has digest set to :md5" do
      check.digest.must_equal :md5
    end
  end
end
