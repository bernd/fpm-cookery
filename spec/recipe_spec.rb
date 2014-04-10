require 'spec_helper'
require 'fpm/cookery/recipe'

describe "Recipe" do
  def stub_dir(dir, path)
    value = path.nil? ? nil : FPM::Cookery::Path.new(path)
    allow(config).to receive(dir).and_return(value)
  end

  let(:klass) do
    Class.new(FPM::Cookery::Recipe)
  end

  let(:config) do
    double('Config', :tmp_root => nil, :pkg_dir => nil, :cache_dir => nil).as_null_object
  end

  let(:recipe) do
    klass.new(__FILE__, config)
  end

  it "sets the filename" do
    expect(recipe.filename.to_s).to eq(__FILE__)
  end

  describe "#workdir" do
    it "sets the workdir" do
      expect(recipe.workdir.to_s).to eq(File.dirname(__FILE__))
    end

    describe "with a relative filename path" do
      it "expands the workdir path" do
        filename = "spec/#{File.basename(__FILE__)}"
        r = klass.new(filename, config)
        expect(r.workdir.to_s).to eq(File.dirname(__FILE__))
      end
    end
  end

  describe "#source_handler" do
    it "returns the recipe's source handler" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
      end

      expect(recipe.source_handler).to be_a(FPM::Cookery::SourceHandler)
    end
  end

  #############################################################################
  # Recipe attributes
  #############################################################################
  def check_attribute(attr, value, expect = nil)
    expect ||= value

    klass.send(attr, value)

    expect(klass.send(attr)).to eq(expect)
    expect(recipe.send(attr)).to eq(expect)
  end

  describe "#arch" do
    it "can be set" do
      check_attribute(:arch, 'i386')
    end
  end

  describe "#description" do
    it "can be set" do
      check_attribute(:description, 'A nice program.')
    end
  end

  describe "#homepage" do
    it "can be set" do
      check_attribute(:homepage, 'http://example.com/')
    end
  end

  describe "#license" do
    it "can be set" do
      check_attribute(:license, 'MIT')
    end
  end

  describe "#maintainer" do
    it "can be set" do
      check_attribute(:maintainer, 'John Doe <john@example.com>')
    end
  end

  describe "#sha256" do
    it "can be set" do
      check_attribute(:sha256, '123456789abcdef')
    end
  end

  describe "#sha1" do
    it "can be set" do
      check_attribute(:sha1, '123456789abcdef')
    end
  end

  describe "#md5" do
    it "can be set" do
      check_attribute(:md5, '123456789abcdef')
    end
  end

  describe "#name" do
    it "can be set" do
      check_attribute(:name, 'redis')
    end
  end

  describe "#revision" do
    it "can be set with a string" do
      check_attribute(:revision, '12')
    end

    it "does not set a default revision" do
      expect(recipe.revision).to eq(nil)
    end
  end

  describe "#section" do
    it "can be set" do
      check_attribute(:section, 'lang')
    end
  end

  describe "#spec" do
    it "can be set" do
      check_attribute(:spec, {:foo => true})
    end
  end

  describe "#vendor" do
    it "can be set" do
      check_attribute(:vendor, 'myvendor')
    end

    it "does not set a default vendor" do
      expect(recipe.vendor).to eq(nil)
    end
  end

  describe "#version" do
    it "can be set" do
      check_attribute(:version, '1.2')
    end
  end

  describe "#pre_install" do
    it "can be set" do
      check_attribute(:pre_install, 'preinstall')
    end
  end

  describe "#post_install" do
    it "can be set" do
      check_attribute(:post_install, 'postinstall')
    end
  end

  describe "#pre_uninstall" do
    it "can be set" do
      check_attribute(:pre_uninstall, 'preuninstall')
    end
  end

  describe "#post_uninstall" do
    it "can be set" do
      check_attribute(:post_uninstall, 'postuninstall')
    end
  end

  describe "#chain_package" do
    it "can be set" do
      check_attribute(:chain_package, true)
    end
  end

  describe "#omnibus_package" do
    it "can be set" do
      check_attribute(:omnibus_package, true)
    end
  end

  describe "#omnibus_dir" do
    it "can be set" do
      check_attribute(:omnibus_dir, '/foo')
    end
  end

  def self.spec_recipe_attribute_list(name, list)
    class_eval %Q{
      describe "##{name}" do
        it "can be set" do
          klass.class_eval do
            #{name} "#{list[0]}"
            #{name} "#{list[1]}"
          end
          expect(klass.#{name}.size).to eq(#{list.size})
          expect(recipe.#{name}.size).to eq(#{list.size})
          expect(klass.#{name}[0]).to eq("#{list[0]}")
          expect(klass.#{name}[1]).to eq("#{list[1]}")
          expect(recipe.#{name}[0]).to eq("#{list[0]}")
          expect(recipe.#{name}[1]).to eq("#{list[1]}")
        end
      end
    }
  end

  spec_recipe_attribute_list(:build_depends, %w{one two})
  spec_recipe_attribute_list(:config_files, %w{one two})
  spec_recipe_attribute_list(:conflicts, %w{one two})
  spec_recipe_attribute_list(:depends, %w{one two})
  spec_recipe_attribute_list(:exclude, %w{one two})
  spec_recipe_attribute_list(:patches, %w{one two})
  spec_recipe_attribute_list(:provides, %w{one two})
  spec_recipe_attribute_list(:replaces, %w{one two})
  spec_recipe_attribute_list(:omnibus_recipes, %w{one two})
  spec_recipe_attribute_list(:chain_recipes, %w{one two})
  spec_recipe_attribute_list(:directories, %w{one two})

  describe ".source" do
    it "sets a source url" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz'
      end

      expect(klass.source).to eq('http://example.com/foo-1.0.tar.gz')
      expect(klass.new(__FILE__, config).source).to eq('http://example.com/foo-1.0.tar.gz')
    end

    describe "with specs" do
      it "sets specs" do
        klass.class_eval do
          source 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
        end

        expect(klass.spec).to eq({:foo => 'bar'})
        expect(klass.new(__FILE__, config).spec).to eq({:foo => 'bar'})
      end
    end
  end

  describe ".url" do
    it "sets a source type (homebrew compat)" do
      klass.class_eval do
        url 'http://example.com/foo-1.0.tar.gz'
      end

      expect(klass.source).to eq('http://example.com/foo-1.0.tar.gz')
      expect(klass.new(__FILE__, config).source).to eq('http://example.com/foo-1.0.tar.gz')
    end

    describe "with specs" do
      it "sets specs" do
        klass.class_eval do
          url 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
        end

        expect(klass.spec).to eq({:foo => 'bar'})
        expect(klass.new(__FILE__, config).spec).to eq({:foo => 'bar'})
      end
    end
  end

  describe "#local_path" do
    it "returns the path to the local source file" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz'
      end

      expect(File.basename(klass.new(__FILE__, config).local_path.to_s)).to eq('foo-1.0.tar.gz')
    end
  end

  describe ".platforms" do
    describe "with a list of platforms" do
      it "allows platform specific settings" do
        klass.class_eval do
          def self.platform; :ubuntu; end

          vendor 'a'

          platforms [:centos, :ubuntu] do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('b')
      end
    end

    describe "with a single platform" do
      it "allows platform specific settings" do
        klass.class_eval do
          def self.platform; :ubuntu; end

          vendor 'a'

          platforms :ubuntu do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('b')
      end
    end

    describe "without a matching platform" do
      it "does not set platform specific stuff" do
        klass.class_eval do
          def self.platform; :centos; end

          vendor 'a'

          platforms :ubuntu do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('a')
      end
    end
  end

  describe ".architectures" do
    before do
      FPM::Cookery::Facts.class_eval do
        def self.arch; :x86_64; end
      end
    end

    describe "with a list of architectures" do
      it "allows arch specific settings" do
        klass.class_eval do
          vendor 'a'

          architectures [:i386, :x86_64] do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('b')
      end
    end

    describe "with a single architecture" do
      it "allows arch specific settings" do
        klass.class_eval do
          vendor 'a'

          architectures :x86_64 do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('b')
      end
    end

    describe "without a matching architecture" do
      it "does not set arch specific settings" do
        klass.class_eval do
          vendor 'a'

          architectures :i386 do
            vendor 'b'
          end
        end

        expect(klass.new(__FILE__, config).vendor).to eq('a')
      end
    end
  end


  #############################################################################
  # Directories
  #############################################################################

  describe "#tmp_root" do
    describe "default" do
      it "defaults to the workdir" do
        expect(recipe.tmp_root).to eq(recipe.workdir)
      end
    end

    describe "set manually" do
      it "sets the tmp_root" do
        stub_dir(:tmp_root, '/tmp')
        expect(recipe.tmp_root.to_s).to eq('/tmp')
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        expect(recipe.tmp_root('test')).to eq(recipe.workdir('test'))
      end
    end
  end

  describe "#destdir" do
    before do
      stub_dir(:tmp_root, '/tmp')
    end

    describe "default" do
      it "sets the destdir" do
        expect(recipe.destdir).to eq(recipe.tmp_root('tmp-dest'))
      end
    end

    describe "set manually" do
      it "sets the destdir" do
        recipe.destdir = '/tmp'
        expect(recipe.destdir.to_s).to eq('/tmp')
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        expect(recipe.destdir('test')).to eq(recipe.tmp_root('tmp-dest/test'))
      end
    end
  end

  describe "#builddir" do
    before do
      stub_dir(:tmp_root, '/tmp')
    end

    describe "default" do
      it "sets the builddir" do
        expect(recipe.builddir).to eq(recipe.tmp_root('tmp-build'))
      end
    end

    describe "set manually" do
      it "sets the builddir" do
        recipe.builddir = '/tmp/jojo'
        expect(recipe.builddir.to_s).to eq('/tmp/jojo')
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        expect(recipe.builddir('test')).to eq(recipe.tmp_root('tmp-build/test'))
      end
    end
  end

  describe "#pkgdir" do
    before do
      stub_dir(:pkg_dir, '/tmp/pkg')
    end

    describe "default" do
      it "sets the pkgdir" do
        stub_dir(:pkg_dir, nil)
        expect(recipe.pkgdir).to eq(recipe.workdir('pkg'))
      end
    end

    describe "set manually" do
      it "sets the pkgdir" do
        recipe.pkgdir = '/tmp/jojo'
        expect(recipe.pkgdir.to_s).to eq('/tmp/jojo')
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        expect(recipe.pkgdir('test').to_s).to eq('/tmp/pkg/test')
      end
    end
  end

  describe "#cachedir" do
    before do
      stub_dir(:cache_dir, '/tmp/cache')
    end

    describe "default" do
      it "sets the cachedir" do
        stub_dir(:cache_dir, nil)
        expect(recipe.cachedir).to eq(recipe.workdir('cache'))
      end
    end

    describe "set manually" do
      it "sets the cachedir" do
        recipe.cachedir = '/tmp/jojo'
        expect(recipe.cachedir.to_s).to eq('/tmp/jojo')
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        expect(recipe.cachedir('test').to_s).to eq('/tmp/cache/test')
      end
    end
  end

  describe "#depends_all" do
    it "returns build_depends and depends package names" do
      klass.depends [:pkg1, :pkg2]
      klass.build_depends [:pkg3, :pkg4]

      expect([:pkg1, :pkg2, :pkg3, :pkg4].all? { |i|
        klass.depends_all.member?(i) && recipe.depends_all.member?(i)
      }).to eq(true)
    end
  end

  describe ".fpm_attributes" do
    it "returns hash object as default" do
      expect(klass.fpm_attributes).to be_a(Hash)
    end

    it "returns same value from instance method with hash assignment" do
      expect(recipe.fpm_attributes).to include({})

      klass.fpm_attributes[:rpm_user] = 'httpd'
      klass.fpm_attributes[:deb_user] = 'apache'

      expect(recipe.fpm_attributes).to include({:rpm_user=>'httpd', :deb_user=>'apache'})
    end

    it "returns same value from instance method with argument assignment" do
      expect(recipe.fpm_attributes).to include({})

      klass.fpm_attributes :rpm_user => 'httpd', :deb_user => 'apache'

      expect(recipe.fpm_attributes).to include({:rpm_user=>'httpd', :deb_user=>'apache'})
    end
  end
end
