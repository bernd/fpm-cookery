require 'spec_helper'
require 'fpm/cookery/lifecycle_hooks'

describe 'LifecycleHooks' do
  let(:object) do
    Class.new do
      attr_accessor :canary

      include FPM::Cookery::LifecycleHooks

      def before_package_create(package)
        self.canary = package
      end

      def after_package_create(package)
        self.canary = package
      end
    end.new
  end

  let(:canary) { Object.new }

  describe 'backward compatibility' do
    describe 'Running :before_package_file_create hook' do
      it 'calls the deprecated :before_package_create hook' do
        object.run_lifecycle_hook(:before_package_file_create, 'filename', canary)

        expect(object.canary).to eq(canary)
      end
    end

    describe 'Running :after_package_file_create hook' do
      it 'calls the deprecated :after_package_create hook' do
        object.run_lifecycle_hook(:after_package_file_create, 'filename', canary)

        expect(object.canary).to eq(canary)
      end
    end
  end
end
