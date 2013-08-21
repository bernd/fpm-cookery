require 'spec_helper'
require 'fpm/cookery/package/maintainer'
require 'ostruct'

describe 'Maintainer' do
  let(:klass) { FPM::Cookery::Package::Maintainer }

  let(:recipe) { OpenStruct.new }
  let(:config) { {} }

  let(:maintainer) { klass.new(recipe, config) }

  def with_shellout_stub(&spec)
    callable = lambda do |key|
      case key
      when 'user.name'
        'John Doe'
      when 'user.email'
        'john@example.com'
      else
        raise "Invalid key: #{key}"
      end
    end

    FPM::Cookery::Shellout.stub(:git_config_get, callable, &spec)
  end

  describe '#to_s' do
    context 'with maintainer set in recipe' do
      it 'returns the recipe maintainer' do
        with_shellout_stub do
          recipe.maintainer = 'Foo <bar@example.com>'

          maintainer.to_s.must_equal 'Foo <bar@example.com>'
        end
      end
    end

    context 'with maintainer set in config' do
      it 'returns the config maintainer' do
        with_shellout_stub do
          config[:maintainer] = 'Foo <bar@example.com>'

          maintainer.to_s.must_equal 'Foo <bar@example.com>'
        end
      end
    end

    context 'with maintainer in config and recipe' do
      it 'returns the config maintainer' do
        with_shellout_stub do
          recipe.maintainer = 'Foo <bar@example.com>'
          config[:maintainer] = 'Jane Doe <jane@example.com>'

          maintainer.to_s.must_equal 'Jane Doe <jane@example.com>'
        end
      end
    end

    context 'without any maintainer set' do
      it 'returns the maintainer from git' do
        with_shellout_stub do
          maintainer.to_s.must_equal 'John Doe <john@example.com>'
        end
      end

    end
  end

  describe '#to_str' do
    it 'converts the maintainer object to a string' do
      with_shellout_stub do
        recipe.maintainer = 'Foo <bar@example.com>'

        maintainer.to_str.must_equal 'Foo <bar@example.com>'
      end
    end
  end
end
