require 'spec_helper'
require 'fpm/cookery/path_helper'

describe "PathHelper" do
  class PathTest
    include FPM::Cookery::PathHelper

    def destdir; FPM::Cookery::Path.new('/tmp/dest') end
  end

  let(:helper) { PathTest.new }

  describe "#installing?" do
    context "with installing set to true" do
      before { helper.installing = true}

      it "returns true" do
        helper.installing?.must_equal true
      end
    end

    context "with installing set to false" do
      before { helper.installing = false }

      it "returns true" do
        helper.installing?.must_equal false
      end
    end
  end

  describe "#with_trueprefix" do
    context "with installing set to true" do
      before { helper.installing = true }

      specify "prefix returns /" do
        helper.with_trueprefix do
          helper.prefix.to_s.must_equal '/usr'
        end
      end

      it "will restore the previous installing value" do
        helper.with_trueprefix {}
        helper.installing.must_equal true
      end
    end

    context "with installing set to false" do
      before { helper.installing = false}

      specify "prefix returns /" do
        helper.with_trueprefix do
          helper.prefix.to_s.must_equal '/usr'
        end
      end

      it "will restore the previous installing value" do
        helper.with_trueprefix {}
        helper.installing.must_equal false
      end
    end
  end
end
