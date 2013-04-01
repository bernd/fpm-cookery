require 'spec_helper'
require 'fpm/cookery/recipe'

class TestRecipe < FPM::Cookery::Recipe
  NAME = :test_recipe
  CHECKSUM = true
end

describe "Recipe" do
  let(:klass) { TestRecipe }

  before do
    # Reset the class level instance variables.
    klass.instance_variables.each do |v|
      klass.instance_variable_set(v, nil)
    end
  end

  let(:recipe) do
    klass.new(__FILE__)
  end

  it "sets the filename" do
    recipe.filename.to_s.must_equal __FILE__
  end

  describe "#workdir" do
    it "sets the workdir" do
      recipe.workdir.to_s.must_equal File.dirname(__FILE__)
    end

    describe "with a relative filename path" do
      it "expands the workdir path" do
        filename = "spec/#{File.basename(__FILE__)}"
        r = klass.new(filename)
        r.workdir.to_s.must_equal File.dirname(__FILE__)
      end
    end
  end

  describe "#source_handler" do
    it "returns the recipe's source handler" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
      end

      recipe.source_handler.must_be_instance_of FPM::Cookery::SourceHandler
    end
  end

  #############################################################################
  # Recipe attributes
  #############################################################################
  def check_attribute(attr, value, expect = nil)
    expect ||= value

    klass.send(attr, value)

    klass.send(attr).must_equal expect
    recipe.send(attr).must_equal expect
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

    it "sets a default revision" do
      recipe.revision.must_equal 0
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

    it "sets a default vendor" do
      recipe.vendor.must_equal 'fpm'
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
          klass.#{name}.size.must_equal #{list.size}
          recipe.#{name}.size.must_equal #{list.size}
          klass.#{name}[0].must_equal "#{list[0]}"
          klass.#{name}[1].must_equal "#{list[1]}"
          recipe.#{name}[0].must_equal "#{list[0]}"
          recipe.#{name}[1].must_equal "#{list[1]}"
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

  describe ".source" do
    it "sets a source url" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz'
      end

      klass.source.must_equal 'http://example.com/foo-1.0.tar.gz'
      klass.new(__FILE__).source.must_equal 'http://example.com/foo-1.0.tar.gz'
    end

    describe "with specs" do
      it "sets specs" do
        klass.class_eval do
          source 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
        end

        klass.spec.must_equal({:foo => 'bar'})
        klass.new(__FILE__).spec.must_equal({:foo => 'bar'})
      end
    end
  end

  describe ".url" do
    it "sets a source type (homebrew compat)" do
      klass.class_eval do
        url 'http://example.com/foo-1.0.tar.gz'
      end

      klass.source.must_equal 'http://example.com/foo-1.0.tar.gz'
      klass.new(__FILE__).source.must_equal 'http://example.com/foo-1.0.tar.gz'
    end

    describe "with specs" do
      it "sets specs" do
        klass.class_eval do
          url 'http://example.com/foo-1.0.tar.gz', :foo => 'bar'
        end

        klass.spec.must_equal({:foo => 'bar'})
        klass.new(__FILE__).spec.must_equal({:foo => 'bar'})
      end
    end
  end

  describe "#local_path" do
    it "returns the path to the local source file" do
      klass.class_eval do
        source 'http://example.com/foo-1.0.tar.gz'
      end

      File.basename(klass.new(__FILE__).local_path.to_s).must_equal 'foo-1.0.tar.gz'
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

        klass.new(__FILE__).vendor.must_equal 'b'
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

        klass.new(__FILE__).vendor.must_equal 'b'
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

        klass.new(__FILE__).vendor.must_equal 'a'
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

        klass.new(__FILE__).vendor.must_equal 'b'
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

        klass.new(__FILE__).vendor.must_equal 'b'
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

        klass.new(__FILE__).vendor.must_equal 'a'
      end
    end
  end


  #############################################################################
  # Directories
  #############################################################################
  describe "#destdir" do
    describe "default" do
      it "sets the destdir" do
        recipe.destdir.must_equal recipe.workdir('tmp-dest')
      end
    end

    describe "set manually" do
      it "sets the destdir" do
        recipe.destdir = '/tmp'
        recipe.destdir.to_s.must_equal '/tmp'
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        recipe.destdir('test').must_equal recipe.workdir('tmp-dest/test')
      end
    end
  end

  describe "#builddir" do
    describe "default" do
      it "sets the builddir" do
        recipe.builddir.must_equal recipe.workdir('tmp-build')
      end
    end

    describe "set manually" do
      it "sets the builddir" do
        recipe.builddir = '/tmp/jojo'
        recipe.builddir.to_s.must_equal '/tmp/jojo'
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        recipe.builddir('test').must_equal recipe.workdir('tmp-build/test')
      end
    end
  end

  describe "#pkgdir" do
    describe "default" do
      it "sets the pkgdir" do
        recipe.pkgdir.must_equal recipe.workdir('pkg')
      end
    end

    describe "set manually" do
      it "sets the pkgdir" do
        recipe.pkgdir = '/tmp/jojo'
        recipe.pkgdir.to_s.must_equal '/tmp/jojo'
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        recipe.pkgdir('test').must_equal recipe.workdir('pkg/test')
      end
    end
  end

  describe "#cachedir" do
    describe "default" do
      it "sets the cachedir" do
        recipe.cachedir.must_equal recipe.workdir('cache')
      end
    end

    describe "set manually" do
      it "sets the cachedir" do
        recipe.cachedir = '/tmp/jojo'
        recipe.cachedir.to_s.must_equal '/tmp/jojo'
      end
    end

    describe "with an argument" do
      it "returns a concatenated path" do
        recipe.cachedir('test').must_equal recipe.workdir('cache/test')
      end
    end
  end
end
