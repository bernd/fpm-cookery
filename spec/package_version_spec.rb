require 'spec_helper'
require 'fpm/cookery/package/version'
require 'ostruct'

describe 'Version' do
  let(:klass) { FPM::Cookery::Package::Version }

  let(:recipe) { OpenStruct.new(:version => '1.2.0') }
  let(:target) { 'deb' }
  let(:config) { {} }

  let(:version) { klass.new(recipe, target, config) }

  describe '#vendor_delimiter' do
    context 'with target deb' do
      it 'returns "+"' do
        version.vendor_delimiter.must_equal '+'
      end
    end

    context 'with target rpm' do
      let(:target) { 'rpm' }

      it 'returns "."' do
        version.vendor_delimiter.must_equal '.'
      end
    end

    context 'with unknown target' do
      let(:target) { '_foo_' }

      it 'returns "-"' do
        version.vendor_delimiter.must_equal '-'
      end
    end
  end

  describe '#vendor' do
    context 'with config.vendor set' do
      it 'returns the config.vendor value' do
        config[:vendor] = 'foo'

        version.vendor.must_equal 'foo'
      end
    end

    context 'with recipe.vendor set' do
      it 'returns the recipe.vendor value' do
        recipe.vendor = 'bar'

        version.vendor.must_equal 'bar'
      end
    end

    context 'with config.vendor and recipe.vendor set' do
      it 'returns the config.vendor value' do
        config[:vendor] = 'foo'
        recipe.vendor = 'bar'

        version.vendor.must_equal 'foo'
      end
    end
  end

  describe '#revision' do
    it 'returns the recipe.revision value' do
      recipe.revision = 24

      version.revision.must_equal 24
    end
  end

  describe '#epoch' do
    it 'returns the version epoch' do
      recipe.version = '4:1.2.3'

      version.epoch.must_equal '4'
    end

    context 'without epoch' do
      it 'returns nil' do
        recipe.version = '1.2.3'

        version.epoch.must_equal nil
      end
    end
  end

  describe '#to_s' do
    it 'returns a string representation of the version' do
      recipe.version = '2.1.3'
      recipe.vendor = 'testing'
      recipe.revision = 5

      version.to_s.must_equal '2.1.3+testing5'
    end

    context 'without vendor' do
      it 'returns a string representation' do
        recipe.version = '2.1.3'
        recipe.revision = 5

        version.to_s.must_equal '2.1.3-5'
      end
    end
  end

  describe '#to_str' do
    let(:target) { 'rpm' }

    it 'returns a string representation of the version' do
      recipe.version = '1.3'
      recipe.vendor = 'foo'
      recipe.revision = 1

      version.to_str.must_equal '1.3.foo1'
    end
  end
end
