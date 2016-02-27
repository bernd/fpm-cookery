require 'spec_helper'
require 'fpm/cookery/environment'
require 'pathname'

describe FPM::Cookery::Environment do
  let(:env) { described_class.new }

  it 'behaves like a hash' do
    env['foo'] = 'bar'

    expect(env['foo']).to eq('bar')
  end

  it 'converts keys to strings on set' do
    env[:foo] = 'bar'

    expect(env['foo']).to eq('bar')
  end

  it 'converts keys to strings on get' do
    env['foo'] = 'bar'

    expect(env[:foo]).to eq('bar')
  end

  it 'converts values to string' do
    env['foo'] = 1
    env['bar'] = Pathname.new('/')

    expect(env['foo']).to eq('1')
    expect(env['bar']).to eq('/')
  end

  it 'deletes a key if the value is set to nil' do
    env['foo'] = 'bar'
    env['foo'] = nil

    expect(env.to_hash).to_not have_key('foo')
  end

  describe '.[]' do
    context 'given a Hash' do
      it 'returns an new instance with keys and values coerced to Strings' do
        expect(described_class[:this => :that]).to eq({"this" => "that"})
      end
    end

    context 'given an array of two-member arrays' do
      it 'returns an new instance with keys and values coerced to Strings' do
        expected = {"this" => "that", "foo" => "bar"}
        expect(described_class[[[:this, :that], [:foo, :bar]]]).to eq(expected)
      end
    end
  end

  describe '#to_hash' do
    it 'returns the data as a hash' do
      env['foo'] = 'bar'

      expect(env.to_hash).to eq({'foo' => 'bar'})
      # Note: not using +be_a+ because +Environment+ inherits from +Hash+, and
      # we want to test that +env.to_hash+ actually is an instance of +Hash+
      # and not an instance of a subclass of +Hash+.
      expect(env.to_hash.class).to eq(Hash)
    end

    it 'returns a copy of the data' do
      env['foo'] = 'bar'

      data = env.to_hash

      env['foo'] = 'nope'

      expect(data).to eq({'foo' => 'bar'})
    end
  end

  describe '#merge' do
    context 'given a Hash' do
      it 'returns a new instance with merged contents' do
        expect(env.merge({:this => :that})).to eq({"this" => "that"})
      end
    end
  end

  describe '#merge!' do
    context 'given a Hash' do
      let(:env_dup) { env.dup }
      it 'merges their contents in-place' do
        env.merge!({:this => :that})
        expect(env).to eq({"this" => "that"})
      end
    end
  end

  describe '#with_clean' do
    it 'returns the return value of the given block' do
      expect(env.with_clean { 'nice' }).to eq('nice')
    end

    it 'removes BUNDLE_GEMFILE from env' do
      env.with_clean do
        expect(ENV).to_not have_key('BUNDLE_GEMFILE')
      end
    end

    it 'removes RUBYOPT from env' do
      env.with_clean do
        expect(ENV).to_not have_key('RUBYOPT')
      end
    end

    it 'removes BUNDLE_BIN_PATH from env' do
      env.with_clean do
        expect(ENV).to_not have_key('BUNDLE_BIN_PATH')
      end
    end

    it 'removes GEM_HOME from env' do
      env.with_clean do
        expect(ENV).to_not have_key('GEM_HOME')
      end
    end

    it 'removes GEM_PATH from env' do
      env.with_clean do
        expect(ENV).to_not have_key('GEM_PATH')
      end
    end

    it 'restores the old environment' do
      env.with_clean { }

      expect(ENV).to have_key('GEM_HOME')
    end

    it 'adds set environment variables' do
      env['GEM_PATH'] = '/custom/path'
      env['FOO'] = 'bar'

      env.with_clean do
        expect(ENV['GEM_PATH']).to eq('/custom/path')
        expect(ENV['FOO']).to eq('bar')
      end
    end

    it 'removes custom variables as well' do
      env['FOO'] = 'bar'

      env.with_clean { }

      expect(ENV).to_not have_key('FOO')
    end
  end
end
