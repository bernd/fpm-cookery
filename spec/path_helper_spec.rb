require 'spec_helper'
require 'fpm/cookery/path_helper'

describe "PathHelper" do
  class PathTest
    include FPM::Cookery::PathHelper

    def destdir; FPM::Cookery::Path.new('/tmp/dest') end
  end

  let(:helper) { PathTest.new }

  describe "path helper methods" do
    [ ['prefix', '/usr'],
      ['etc', '/etc'],
      ['opt', '/opt'],
      ['var', '/var'],
      ['bin', '/usr/bin'],
      ['doc', '/usr/share/doc'],
      ['include', '/usr/include'],
      ['info', '/usr/share/info'],
      ['lib', '/usr/lib'],
      ['libexec', '/usr/libexec'],
      ['man', '/usr/share/man'],
      ['man1', '/usr/share/man/man1'],
      ['man2', '/usr/share/man/man2'],
      ['man3', '/usr/share/man/man3'],
      ['man4', '/usr/share/man/man4'],
      ['man5', '/usr/share/man/man5'],
      ['man6', '/usr/share/man/man6'],
      ['man7', '/usr/share/man/man7'],
      ['man8', '/usr/share/man/man8'],
      ['sbin', '/usr/sbin'],
      ['share', '/usr/share'] ].each do |m|

      name, path = m

      describe "##{name}" do
        context "without an argument" do
          it "returns #{path}" do
            helper.send(name).to_s.must_equal path
          end
        end

        context "with an argument" do
          it "adds the argument to the path" do
            helper.send(name, 'foo/bar').to_s.must_equal "#{path}/foo/bar"
          end
        end

        context "with a nil argument" do
          it "does not add anything to the path" do
            helper.send(name, nil).to_s.must_equal path
          end
        end

        context "with installing set to true" do
          before { helper.installing = true}

          it "adds the destdir as prefix" do
            helper.send(name, 'blah').to_s.must_equal "#{helper.destdir}#{path}/blah"
          end
        end

        context "with omnibus_installing set to true" do
          before { helper.omnibus_installing = true }

          it "does not add anything to the path" do
            helper.send(name, 'blah').to_s.must_equal "#{path}/blah"
          end
        end

        context "with omnibus_installing and installing set to true" do
          before { helper.omnibus_installing = true ; helper.installing = true }

          it "does not add anything to the path" do
            helper.send(name, 'blah').to_s.must_equal "#{path}/blah"
          end
        end
      end
    end
  end

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

  describe "#omnibus_installing?" do
    context "with omnibus_installing set to true" do
      before { helper.omnibus_installing = true }

      it "returns true" do
        helper.omnibus_installing?.must_equal true
      end
    end

    context "with omnibus_installing set to false" do
      before { helper.omnibus_installing = false }

      it "returns false" do
        helper.omnibus_installing?.must_equal false
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
