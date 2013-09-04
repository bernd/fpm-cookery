require 'spec_helper'
require 'fpm/cookery/package/package'

require 'fpm/package/dir'
require 'fpm/cookery/recipe'

describe 'Package' do
  let(:config) { {} }

  let(:package_bare_class) do
    Class.new(FPM::Cookery::Package::Package)
  end

  let(:package_bare) do
    package_bare_class.new(recipe, config)
  end

  let(:package_class) do
    Class.new(FPM::Cookery::Package::Package) {
      attr_reader :test_package_setup_run, :test_package_input_run

      def fpm_object
        FPM::Package::Dir.new
      end

      def package_setup
        @test_package_setup_run = true
      end

      def package_input
        @test_package_input_run = true
      end
    }
  end

  let(:package) do
    package_class.new(recipe, config)
  end

  let(:recipe) do
    Class.new(FPM::Cookery::Recipe) do
      description 'a test package'
      name 'foo'
      homepage 'http://example.com'
      section 'langs'
      arch 'all'
      depends 'ab', 'c'
      conflicts 'xz', 'y'
      provides 'foo-package'
      replaces 'foo-old'
      config_files '/etc/foo.conf'
    end
  end

  describe 'fpm package object initialization' do
    it 'sets name' do
      package.fpm.name.must_equal 'foo'
    end

    it 'sets url' do
      package.fpm.url.must_equal 'http://example.com'
    end

    it 'sets category' do
      package.fpm.category.must_equal 'langs'
    end

    context 'without section set' do
      it 'sets category to "optional"' do
        recipe.instance_variable_set(:@section, nil)

        package.fpm.category.must_equal 'optional'
      end
    end

    it 'sets the description' do
      package.fpm.description.must_equal 'a test package'
    end

    it 'sets the architecture' do
      package.fpm.architecture.must_equal 'all'
    end

    it 'sets the dependencies' do
      package.fpm.dependencies.must_equal ['ab', 'c']
    end

    it 'sets the conflicts' do
      package.fpm.conflicts.must_equal ['xz', 'y']
    end

    it 'sets the provides' do
      package.fpm.provides.must_equal ['foo-package']
    end

    it 'sets the replaces' do
      package.fpm.replaces.must_equal ['foo-old']
    end

    it 'sets the config_files' do
      package.fpm.config_files.must_equal ['/etc/foo.conf']
    end

    describe 'attributes' do
      let(:attributes) { package.fpm.attributes }

      it 'sets deb_compression' do
        attributes[:deb_compression].must_equal 'gzip'
      end

      it 'sets deb_user' do
        attributes[:deb_user].must_equal 'root'
      end

      it 'sets deb_group' do
        attributes[:deb_group].must_equal 'root'
      end

      it 'sets rpm_compression' do
        attributes[:rpm_compression].must_equal 'gzip'
      end

      it 'sets rpm_digest' do
        attributes[:rpm_digest].must_equal 'md5'
      end

      it 'sets rpm_user' do
        attributes[:rpm_user].must_equal 'root'
      end

      it 'sets rpm_group' do
        attributes[:rpm_group].must_equal 'root'
      end

      it 'sets rpm_defattrfile' do
        attributes[:rpm_defattrfile].must_equal '-'
      end

      it 'sets rpm_defattrdir' do
        attributes[:rpm_defattrdir].must_equal '-'
      end

      it 'sets excludes' do
        attributes[:excludes].must_equal []
      end
    end

    it 'calls the package_setup method' do
      package.test_package_setup_run.must_equal true
    end

    it 'calls the package_input method' do
      package.test_package_input_run.must_equal true
    end

    context 'without package_input method defined' do
      before do
        package_bare_class.class_eval do
          def fpm_class
          end
        end
      end

      it 'raises a MethodNotImplemented error' do
        proc { package_bare }.must_raise FPM::Cookery::Error::MethodNotImplemented
      end
    end

    context 'without fpm_object method defined' do
      before do
        package_bare_class.class_eval do
          def package_input
          end
        end
      end

      it 'raises a MethodNotImplemented error' do
        proc { package_bare }.must_raise FPM::Cookery::Error::MethodNotImplemented
      end
    end
  end
end
