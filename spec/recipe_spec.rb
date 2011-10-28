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
  def self.spec_recipe_attribute(name, value)
    value = Numeric === value ? value : "\"#{value}\""
    class_eval %Q{
      describe "##{name}" do
        it "can be set" do
          klass.class_eval { #{name} #{value} }
          klass.#{name}.must_equal #{value}
          recipe.#{name}.must_equal #{value}
        end
      end
    }
  end

  spec_recipe_attribute(:arch, 'i386')
  spec_recipe_attribute(:description, 'A nice program.')
  spec_recipe_attribute(:homepage, 'http://example.com')
  spec_recipe_attribute(:maintainer, 'John Doe <john@example.com>')
  spec_recipe_attribute(:sha256, '123456789abcdef')
  spec_recipe_attribute(:sha1, '123456789abcdef')
  spec_recipe_attribute(:md5, '123456789abcdef')
  spec_recipe_attribute(:name, 'redis')
  spec_recipe_attribute(:revision, 12)
  spec_recipe_attribute(:section, 'lang')
  # NOTE(lusis)
  # see comment in `SourceHandler#initialize` r.e. options as `String`
  spec_recipe_attribute(:spec, {:foo => true})
  spec_recipe_attribute(:vendor, 'myvendor')
  spec_recipe_attribute(:version, '1.2')
  spec_recipe_attribute(:pre_install, 'preinstall')
  spec_recipe_attribute(:post_install, 'postinstall')
  spec_recipe_attribute(:pre_uninstall, 'preuninstall')
  spec_recipe_attribute(:post_uninstall, 'postuninstall')

  describe "#revision" do
    it "sets a default revision" do
      recipe.revision.must_equal 0
    end
  end

  describe "#vendor" do
    it "sets a default vendor" do
      recipe.vendor.must_equal 'fpm'
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
