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
      directories '/var/lib/foo', '/var/cache/foo'
    end
  end

  describe 'fpm package object initialization' do
    it 'sets name' do
      expect(package.fpm.name).to eq('foo')
    end

    it 'sets url' do
      expect(package.fpm.url).to eq('http://example.com')
    end

    it 'sets category' do
      expect(package.fpm.category).to eq('langs')
    end

    context 'without section set' do
      it 'sets category to "optional"' do
        recipe.instance_variable_set(:@section, nil)

        expect(package.fpm.category).to eq('optional')
      end
    end

    it 'sets the description' do
      expect(package.fpm.description).to eq('a test package')
    end

    it 'sets the architecture' do
      expect(package.fpm.architecture).to eq('all')
    end

    it 'sets the dependencies' do
      expect(package.fpm.dependencies).to eq(['ab', 'c'])
    end

    it 'sets the conflicts' do
      expect(package.fpm.conflicts).to eq(['xz', 'y'])
    end

    it 'sets the provides' do
      expect(package.fpm.provides).to eq(['foo-package'])
    end

    it 'sets the replaces' do
      expect(package.fpm.replaces).to eq(['foo-old'])
    end

    it 'sets the config_files' do
      expect(package.fpm.config_files).to eq(['/etc/foo.conf'])
    end

    it 'sets the directories' do
      expect(package.fpm.directories).to eq(['/var/lib/foo', '/var/cache/foo'])
    end

    describe 'attributes' do
      let(:attributes) { package.fpm.attributes }

      it 'sets deb_compression' do
        expect(attributes[:deb_compression]).to eq('gz')
      end

      it 'sets deb_user' do
        expect(attributes[:deb_user]).to eq('root')
      end

      it 'sets deb_group' do
        expect(attributes[:deb_group]).to eq('root')
      end

      it 'sets rpm_compression' do
        expect(attributes[:rpm_compression]).to eq('gzip')
      end

      it 'sets rpm_digest' do
        expect(attributes[:rpm_digest]).to eq('md5')
      end

      it 'sets rpm_user' do
        expect(attributes[:rpm_user]).to eq('root')
      end

      it 'sets rpm_group' do
        expect(attributes[:rpm_group]).to eq('root')
      end

      it 'sets rpm_defattrfile' do
        expect(attributes[:rpm_defattrfile]).to eq('-')
      end

      it 'sets rpm_defattrdir' do
        expect(attributes[:rpm_defattrdir]).to eq('-')
      end

      it 'sets excludes' do
        expect(attributes[:excludes]).to eq([])
      end
    end

    describe '.fpm_attributes' do
      let(:recipe) do
        # Ensure Recipe.inherited() to be called before handling fpm_attributes.
        recipe_class = Class.new(FPM::Cookery::Recipe)
        recipe_class.instance_eval do
          fpm_attributes :deb_user=>'deb_user', :rpm_user=>'rpm_user'
        end
        recipe_class
      end

      it 'overwrites default fpm attributes in Package class' do
        expect(package.fpm.attributes).to include({:deb_user=>'deb_user', :rpm_user=>'rpm_user'})
      end
    end

    it 'calls the package_setup method' do
      expect(package.test_package_setup_run).to eq(true)
    end

    it 'calls the package_input method' do
      expect(package.test_package_input_run).to eq(true)
    end

    context 'without package_input method defined' do
      before do
        package_bare_class.class_eval do
          def fpm_class
          end
        end
      end

      it 'raises a MethodNotImplemented error' do
        expect {
          package_bare
        }.to raise_error(FPM::Cookery::Error::MethodNotImplemented)
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
        expect {
          package_bare
        }.to raise_error(FPM::Cookery::Error::MethodNotImplemented)
      end
    end
  end
end
