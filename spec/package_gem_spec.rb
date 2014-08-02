require 'spec_helper'
require 'fpm/cookery/package/gem'
require 'fpm/cookery/recipe'

describe FPM::Cookery::Package::Gem do
  let(:config) { {} }

  let(:recipe) do
    Class.new(FPM::Cookery::RubyGemRecipe) do
      description 'a test package'
      name 'foo'
      version '1.1.1'
    end
  end

  let(:package) do
    described_class.new(recipe, config)
  end

  let(:fpm) do
    double('FPM').as_null_object
  end

  before do
    allow(FPM::Package::Gem).to receive(:new).and_return(fpm)
  end

  context '#package_input' do
    it 'calls the fpm package creation with a clean environment' do
      expect(fpm).to receive(:input) do |*args|
        expect(ENV).to_not have_key('GEM_HOME')
      end

      package # Trigger object creation and package_input call.
    end
  end
end
