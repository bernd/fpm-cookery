require 'spec_helper'
require 'fpm/cookery/utils'

describe FPM::Cookery::Utils do
  class TestUtils
    include FPM::Cookery::Utils

    def run_configure_no_arg
      configure
    end

    def run_configure
      configure '--prefix=/usr', '--test=yo'
    end

    def run_configure_hash
      configure :hello_world => true, :prefix => '/usr', 'a-dash' => 1
    end

    def run_configure_mix
      configure '--first=okay', '--second=okay', :hello_world => true, :prefix => '/usr', 'a-dash' => 1
    end

    def run_go_build
      go 'build', '-mod=vendor', '-v'
    end

    def run_go_build_hash
      go :build, :mod => 'vendor', :v => true
    end

    def run_patch_level
      patch 'file.patch', 'one'
    end

    def run_patch_missing
      patch 'missing.patch'
    end
  end

  let(:test) { TestUtils.new }

  before do
    # Avoid shellout.
    allow(test).to receive(:system).and_return('success')
  end

  describe '#configure' do
    context 'with a list of string arguments' do
      it 'calls ./configure with the correct arguments' do
        expect(test).to receive(:system).with('./configure', '--prefix=/usr', '--test=yo')
        test.run_configure
      end
    end

    context 'with hash arguments' do
      it 'calls ./configure with the correct arguments' do
        expect(test).to receive(:system).with('./configure', '--hello-world', '--prefix=/usr', '--a-dash=1')
        test.run_configure_hash
      end
    end

    context 'with string and hash arguments' do
      it 'calls ./configure with the correct arguments' do
        expect(test).to receive(:system).with('./configure', '--first=okay', '--second=okay', '--hello-world', '--prefix=/usr', '--a-dash=1')
        test.run_configure_mix
      end
    end

    context 'without any arguments' do
      it 'calls ./configure without any arguments' do
        expect(test).to receive(:system).with('./configure')
        test.run_configure_no_arg
      end
    end
  end
  describe '#go' do
    context 'with a list of string arguments' do
      it 'calls go with the correct arguments' do
        expect(test).to receive(:system).with('go', 'build', '-mod=vendor', '-v')
        test.run_go_build
      end
    end

    context 'with hash arguments' do
      it 'calls go with the correct arguments' do
        expect(test).to receive(:system).with('go', 'build', '--mod=vendor', '--v')
        test.run_go_build_hash
      end
    end
  end
  describe '#patch' do
    it 'raises error if level is not an integer' do
      expect { test.run_patch_level }.to raise_error("patch level must be integer")
    end

    it 'raises error if file does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      expect { test.run_patch_missing }.to raise_error("missing.patch does not exist")
    end
  end
end
