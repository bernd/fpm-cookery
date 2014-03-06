require 'spec_helper'
require 'fpm/cookery/path_helper'

describe "PathHelper" do
  let(:helper) do
    Class.new {
      include FPM::Cookery::PathHelper

      def destdir; FPM::Cookery::Path.new('/tmp/dest') end
    }.new
  end

  describe "path helper methods" do
    [ ['prefix', '/usr'],
      ['root_prefix', '/'],
      ['root', '/'],
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
        def c(path); path.gsub(%r{//}, '/'); end

        context "without an argument" do
          it "returns #{path}" do
            expect(helper.send(name).to_s).to eq(path)
          end
        end

        context "with an argument" do
          it "adds the argument to the path" do
            expect(helper.send(name, 'foo/bar').to_s).to eq(c("#{path}/foo/bar"))
          end
        end

        context "with a nil argument" do
          it "does not add anything to the path" do
            expect(helper.send(name, nil).to_s).to eq(path)
          end
        end

        context "with installing set to true" do
          before { helper.installing = true}

          it "adds the destdir as prefix" do
            expect(helper.send(name, 'blah').to_s).to eq(c("#{helper.destdir}#{path}/blah"))
          end
        end

        context "with omnibus_installing set to true" do
          before { helper.omnibus_installing = true }

          it "does not add anything to the path" do
            expect(helper.send(name, 'blah').to_s).to eq(c("#{path}/blah"))
          end
        end

        context "with omnibus_installing and installing set to true" do
          before { helper.omnibus_installing = true ; helper.installing = true }

          it "does not add anything to the path" do
            expect(helper.send(name, 'blah').to_s).to eq(c("#{path}/blah"))
          end
        end
      end
    end
  end

  describe "#installing?" do
    context "with installing set to true" do
      before { helper.installing = true}

      it "returns true" do
        expect(helper.installing?).to eq(true)
      end
    end

    context "with installing set to false" do
      before { helper.installing = false }

      it "returns true" do
        expect(helper.installing?).to eq(false)
      end
    end
  end

  describe "#omnibus_installing?" do
    context "with omnibus_installing set to true" do
      before { helper.omnibus_installing = true }

      it "returns true" do
        expect(helper.omnibus_installing?).to eq(true)
      end
    end

    context "with omnibus_installing set to false" do
      before { helper.omnibus_installing = false }

      it "returns false" do
        expect(helper.omnibus_installing?).to eq(false)
      end
    end
  end

  describe "#with_trueprefix" do
    context "with installing set to true" do
      before { helper.installing = true }

      specify "prefix returns /" do
        helper.with_trueprefix do
          expect(helper.prefix.to_s).to eq('/usr')
        end
      end

      it "will restore the previous installing value" do
        helper.with_trueprefix {}
        expect(helper.installing).to eq(true)
      end
    end

    context "with installing set to false" do
      before { helper.installing = false}

      specify "prefix returns /" do
        helper.with_trueprefix do
          expect(helper.prefix.to_s).to eq('/usr')
        end
      end

      it "will restore the previous installing value" do
        helper.with_trueprefix {}
        expect(helper.installing).to eq(false)
      end
    end
  end
end
