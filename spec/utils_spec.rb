require 'spec_helper'
require 'fpm/cookery/utils'

describe FPM::Cookery::Utils do
  class TestUtils
    include FPM::Cookery::Utils

    def run_configure_no_arg
      configure
    end

    def run_cleanenv_safesystem(*args)
      cleanenv_safesystem(*args)
    end

    def run_with_cleanenv(&block)
      with_cleanenv do
        block.call
      end
    end
  end

  let(:test) { TestUtils.new }

  before do
    # Avoid shellout.
    allow(test).to receive(:system).and_return('success')
  end

  describe '#configure' do
    context 'without any arguments' do
      it 'calls ./configure without any arguments' do
        expect(test).to receive(:system).with('./configure')
        test.run_configure_no_arg
      end
    end
  end

  describe '#cleanenv_safesystem' do
    it 'executes system with the given commands' do
      expect(test).to receive(:safesystem).with('foo', 'bar')
      test.run_cleanenv_safesystem('foo', 'bar')
    end

    it 'executes system with a clean environment' do
      expect(test).to receive(:safesystem) do |*args|
        expect(ENV).to_not have_key('BUNDLE_GEMFILE')
        expect(ENV).to_not have_key('RUBYOPT')
        expect(ENV).to_not have_key('BUNDLE_BIN_PATH')
        expect(ENV).to_not have_key('GEM_HOME')
        expect(ENV).to_not have_key('GEM_PATH')
      end

      test.run_cleanenv_safesystem('foo', 'bar')
    end

    it 'uses #with_cleanenv' do
      expect(test).to receive(:with_cleanenv)
      test.run_cleanenv_safesystem('foo', 'bar')
    end

    it 'returns the system return value' do
      expect(test.run_cleanenv_safesystem('foo')).to eq('success')
    end
  end

  describe '#with_cleanenv' do
    it 'returns the return value of the given block' do
      value = test.run_with_cleanenv { 'nice' }

      expect(value).to eq('nice')
    end

    it 'removes BUNDLE_GEMFILE from env' do
      test.run_with_cleanenv do
        expect(ENV).to_not have_key('BUNDLE_GEMFILE')
      end
    end

    it 'removes RUBYOPT from env' do
      test.run_with_cleanenv do
        expect(ENV).to_not have_key('RUBYOPT')
      end
    end

    it 'removes BUNDLE_BIN_PATH from env' do
      test.run_with_cleanenv do
        expect(ENV).to_not have_key('BUNDLE_BIN_PATH')
      end
    end

    it 'removes GEM_HOME from env' do
      test.run_with_cleanenv do
        expect(ENV).to_not have_key('GEM_HOME')
      end
    end

    it 'removes GEM_PATH from env' do
      test.run_with_cleanenv do
        expect(ENV).to_not have_key('GEM_PATH')
      end
    end
  end
end
