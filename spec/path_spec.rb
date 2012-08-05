require 'spec_helper'
require 'fpm/cookery/path'
require 'tmpdir'

describe "Path" do
  describe ".pwd" do
    it "returns the current dir" do
      Dir.chdir('/tmp') do
        FPM::Cookery::Path.pwd.to_s.must_equal '/tmp'
      end
    end

    it "adds the given path to the current dir" do
      Dir.chdir('/tmp') do
        FPM::Cookery::Path.pwd('foo').to_s.must_equal '/tmp/foo'
      end
    end
  end

  describe "#+" do
    let(:path) { FPM::Cookery::Path.new('/foo') }

    describe "with a path fragmet" do
      it "returns a new concatenated path object" do
        (path + 'bar').to_s.must_equal '/foo/bar'
      end
    end

    describe "with an absolute path" do
      it "overwrites the old path" do
        (path + '/bar').to_s.must_equal '/bar'
      end
    end

    describe "with an empty fragment" do
      it "does't modify the path" do
        (path + '').to_s.must_equal '/foo'
      end
    end
  end

  describe "#/" do
    let(:path) { FPM::Cookery::Path.new('/foo') }

    describe "with a path fragment" do
      it "returns a new concatenated path object" do
        (path/'bar').to_s.must_equal '/foo/bar'
      end
    end

    describe "with an absolute path" do
      it "returns a new concatenated path object" do
        (path/'/baz').to_s.must_equal '/foo/baz'
      end
    end

    describe "with a nil argument" do
      it "does not modify the path" do
        (path/nil).to_s.must_equal '/foo'
      end
    end
  end

  describe "#mkdir" do
    it "creates the directory" do
      dir = Dir.mktmpdir
      FileUtils.rm_rf(dir)
      File.exists?(dir).must_equal false

      FPM::Cookery::Path.new(dir).mkdir
      File.exists?(dir).must_equal true

      FileUtils.rm_rf(dir)
    end

    describe "directory exists" do
      it "does not throw an error" do
        dir = Dir.mktmpdir
        File.exists?(dir).must_equal true

        FPM::Cookery::Path.new(dir).mkdir.must_equal [dir]

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

          File.exist?(path/File.basename(__FILE__)).must_equal true
          File.exist?(path/'spec_helper.rb').must_equal true
        end
      end
    end

    describe "with a hash as src" do
      it "installs the file with a new basename" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__) => 'foo.rb')

          File.exist?(path/'foo.rb').must_equal true
        end
      end
    end

    describe "with a string as src" do
      it "installs the file" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__))

          File.exist?(path/'spec_helper.rb').must_equal true
        end
      end
    end

    describe "with a new basename argument" do
      it "installs the file with a new basename" do
        Dir.mktmpdir do |dir|
          path = FPM::Cookery::Path.new(dir)
          path.install(File.expand_path('../spec_helper.rb', __FILE__), 'foo.rb')

          File.exist?(path/'foo.rb').must_equal true
        end
      end
    end
  end
end
