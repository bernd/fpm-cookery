require 'spec_helper'
require 'fpm/cookery/package/version'
require 'ostruct'

describe 'Version' do
  let(:target) { 'deb' }

  let(:klass) { FPM::Cookery::Package::Version }

  let(:recipe) { OpenStruct.new(:version => '1.2.0') }
  let(:config) { {} }

  let(:version) { klass.new(recipe, target, config) }

  describe '#vendor_delimiter' do
    context 'with target deb' do
      it 'returns "+"' do
        expect(version.vendor_delimiter).to eq('+')
      end
    end

    context 'with target rpm' do
      let(:target) { 'rpm' }

      it 'returns "."' do
        expect(version.vendor_delimiter).to eq('.')
      end
    end

    context 'with unknown target' do
      let(:target) { '_foo_' }

      it 'returns "-"' do
        expect(version.vendor_delimiter).to eq('-')
      end
    end
  end

  describe '#vendor' do
    context 'with config.vendor set' do
      it 'returns the config.vendor value' do
        config[:vendor] = 'foo'

        expect(version.vendor).to eq('foo')
      end
    end

    context 'with recipe.vendor set' do
      it 'returns the recipe.vendor value' do
        recipe.vendor = 'bar'

        expect(version.vendor).to eq('bar')
      end
    end

    context 'with config.vendor and recipe.vendor set' do
      it 'returns the config.vendor value' do
        config[:vendor] = 'foo'
        recipe.vendor = 'bar'

        expect(version.vendor).to eq('foo')
      end
    end
  end

  describe '#revision' do
    it 'returns the recipe.revision value' do
      recipe.revision = 24

      expect(version.revision).to eq(24)
    end
  end

  describe '#epoch' do
    it 'returns the version epoch' do
      recipe.version = '4:1.2.3'

      expect(version.epoch).to eq('4')
    end

    context 'without epoch' do
      it 'returns nil' do
        recipe.version = '1.2.3'

        expect(version.epoch).to eq(nil)
      end
    end
  end

  describe '#to_s' do
    it 'returns a string representation of the version' do
      recipe.version = '2.1.3'
      recipe.vendor = 'testing1'
      recipe.revision = 5

      expect(version.to_s).to eq('2.1.3-5+testing1')
    end

    context 'with target rpm' do
      let(:target) { 'rpm' }

      it 'returns a string representation of the version' do
        recipe.version = '2.1.3'
        recipe.vendor = 'testing1'
        recipe.revision = 5

        expect(version.to_s).to eq('2.1.3-5.testing1')
      end
    end

    context 'without vendor' do
      it 'returns a string representation' do
        recipe.version = '2.1.3'
        recipe.revision = 5

        expect(version.to_s).to eq('2.1.3-5')
      end

      context 'with target rpm' do
        let(:target) { 'rpm' }

        it 'returns a string representation of the version' do
          recipe.version = '2.1.3'
          recipe.revision = 5

          expect(version.to_s).to eq('2.1.3-5')
        end
      end
    end
  end

  describe '#to_str' do
    let(:target) { 'rpm' }

    it 'returns a string representation of the version' do
      recipe.version = '1.3'
      recipe.vendor = 'foo'
      recipe.revision = 1

      expect(version.to_str).to eq('1.3-1.foo')
    end
  end
end
