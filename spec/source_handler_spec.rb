require 'spec_helper'
require 'fpm/cookery/source'
require 'fpm/cookery/source_handler'

describe 'SourceHandler' do
  let(:cachedir) { FPM::Cookery::Path.new('/tmp/cache') }
  let(:builddir) { FPM::Cookery::Path.new('/tmp/build') }

  describe "#fetchable?" do
    context "when using the noop source handler" do
      it "always returns true" do
        nil_source = FPM::Cookery::Source.new(nil, :with => :noop)
        empty_source = FPM::Cookery::Source.new('', :with => :noop)

        nil_handler = FPM::Cookery::SourceHandler.new(nil_source, cachedir, builddir)
        empty_handler = FPM::Cookery::SourceHandler.new(empty_source, cachedir, builddir)

        expect(nil_handler.fetchable?).to eq(true)
        expect(empty_handler.fetchable?).to eq(true)
      end
    end

    context "otherwise" do
      it "returns true when the source URI is non-empty" do
        fetchable_sources = [
          ['https://somedomain.io/project-1.2-3.tar.xz'],
          ['https://git.mysite.cat/atonic.git', :with => :git],
          ['/var/src', :with => :directory],
        ].map { |s| FPM::Cookery::Source.new(*s) }

        unfetchable_sources = [
          [''],
          [nil, :with => :git],
          ['', :with => :directory],
        ].map { |s| FPM::Cookery::Source.new(*s) }

        fetchable_handlers = fetchable_sources.map { |fs| FPM::Cookery::SourceHandler.new(fs, cachedir, builddir) }
        unfetchable_handlers = unfetchable_sources.map { |us| FPM::Cookery::SourceHandler.new(us, cachedir, builddir) }

        expect(fetchable_handlers.map(&:fetchable?)).to all(eq(true))
        expect(unfetchable_handlers.map(&:fetchable?)).to all(eq(false))
      end
    end
  end
end
