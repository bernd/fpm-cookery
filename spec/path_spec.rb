require 'spec_helper'
require 'fpm/cookery/path'
require 'tmpdir'

describe "Path" do
  describe ".pwd" do
    it "returns the current dir" do
      Dir.chdir('/tmp') do
        expect(FPM::Cookery::Path.pwd.to_s).to match(%r{/tmp|/private/tmp})
      end
    end

    it "adds the given path to the current dir" do
      Dir.chdir('/tmp') do
        expect(FPM::Cookery::Path.pwd('foo').to_s).to match(%r{/tmp|/private/tmp})
      end
    end
  end

  describe "#+" do
    let(:path) { FPM::Cookery::Path.new('/foo') }

    describe "with a path fragmet" do
      it "returns a new concatenated path object" do
        expect((path + 'bar').to_s).to eq('/foo/bar')
      end
    end

    describe "with an absolute path" do
      it "overwrites the old path" do
        expect((path + '/bar').to_s).to eq('/bar')
      end
    end

    describe "with an empty fragment" do
      it "does't modify the path" do
        expect((path + '').to_s).to eq('/foo')
      end
    end
  end

  describe "#/" do
    let(:path) { FPM::Cookery::Path.new('/foo') }

    describe "with a path fragment" do
      it "returns a new concatenated path object" do
        expect((path/'bar').to_s).to eq('/foo/bar')
      end
    end

    describe "with an absolute path" do
      it "returns a new concatenated path object" do
        expect((path/'/baz').to_s).to eq('/foo/baz')
      end
    end

    describe "with a nil argument" do
      it "does not modify the path" do
        expect((path/nil).to_s).to eq('/foo')
      end
    end
  end

  describe "#mkdir" do
    it "creates the directory" do
      dir = Dir.mktmpdir
      FileUtils.rm_rf(dir)
      expect(File.exists?(dir)).to eq(false)

      FPM::Cookery::Path.new(dir).mkdir
      expect(File.exists?(dir)).to eq(true)

      FileUtils.rm_rf(dir)
    end

    describe "directory exists" do
      it "does not throw an error" do
        dir = Dir.mktmpdir
        expect(File.exists?(dir)).to eq(true)

        expect(FPM::Cookery::Path.new(dir).mkdir).to eq([dir])

        FileUtils.rm_rf(dir)
      end
    end
  end

  describe "#install" do
    describe "with an array as src" do
      it "installs every file in the list" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install([__FILE__, File.expand_path('../spec_helper.rb', __FILE__)])

          expect(File.exist?(path/File.basename(__FILE__))).to eq(true)
          expect(File.exist?(path/'spec_helper.rb')).to eq(true)
        end
      end
    end

    describe "with a hash as src" do
      it "installs the file with a new basename" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__) => 'foo.rb')

          expect(File.exist?(path/'foo.rb')).to eq(true)
        end
      end
    end

    describe "with a string as src" do
      it "installs the file" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__))

          expect(File.exist?(path/'spec_helper.rb')).to eq(true)
        end
      end
    end

    describe "with a new basename argument" do
      it "installs the file with a new basename" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__), 'foo.rb')

          expect(File.exist?(path/'foo.rb')).to eq(true)
        end
      end
    end
  end
end
