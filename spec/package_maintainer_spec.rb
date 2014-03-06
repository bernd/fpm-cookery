require 'spec_helper'
require 'fpm/cookery/package/maintainer'
require 'ostruct'

describe 'Maintainer' do
  let(:klass) { FPM::Cookery::Package::Maintainer }

  let(:recipe) { OpenStruct.new }
  let(:config) { {} }

  let(:maintainer) { klass.new(recipe, config) }

  def with_env_stub(env)
    old_env = ENV.to_hash
    env.each do |key, value|
      ENV[key] = value
    end
    yield
  ensure
    ENV.replace(old_env)
  end

  before do
    allow(FPM::Cookery::Shellout).to receive(:git_config_get).with('user.name').and_return('John Doe')
    allow(FPM::Cookery::Shellout).to receive(:git_config_get).with('user.email').and_return('john@example.com')
  end

  describe '#to_s' do
    context 'with maintainer set in recipe' do
      it 'returns the recipe maintainer' do
        recipe.maintainer = 'Foo <bar@example.com>'
        expect(maintainer.to_s).to eq('Foo <bar@example.com>')
      end
    end

    context 'with maintainer set in config' do
      it 'returns the config maintainer' do
        config[:maintainer] = 'Foo <bar@example.com>'

        expect(maintainer.to_s).to eq('Foo <bar@example.com>')
      end
    end

    context 'with maintainer in config and recipe' do
      it 'returns the config maintainer' do
        recipe.maintainer = 'Foo <bar@example.com>'
        config[:maintainer] = 'Jane Doe <jane@example.com>'

        expect(maintainer.to_s).to eq('Jane Doe <jane@example.com>')
      end
    end

    context 'without any maintainer set' do
      it 'returns the maintainer from git' do
        expect(maintainer.to_s).to eq('John Doe <john@example.com>')
      end
    end

    context 'without valid git data' do
      before do
        allow(FPM::Cookery::Shellout).to receive(:git_config_get).and_return(nil)
        allow(Socket).to receive(:gethostname).and_return('hostname')
      end

      it 'returns a default maintainer' do
        with_env_stub('USER' => 'john') do
          expect(maintainer.to_s).to eq('<john@hostname>')
        end
      end
    end
  end

  describe '#to_str' do
    it 'converts the maintainer object to a string' do
      recipe.maintainer = 'Foo <bar@example.com>'

      expect(maintainer.to_str).to eq('Foo <bar@example.com>')
    end
  end
end
