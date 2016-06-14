require 'spec_helper'
require 'fpm/cookery/package/dir'
require 'fpm/cookery/recipe'

describe FPM::Cookery::Package::Dir do
  let(:config) { { :input => input } }
  let(:input) { %w{foo bar baz} }

  let(:recipe) do
    Class.new(FPM::Cookery::Recipe) do
      description 'a test package'
      name 'boo'
      version '8.5'
    end
  end

  let(:package) do
    described_class.new(recipe, config)
  end

  let(:fpm) do
    double('FPM').as_null_object
  end

  before do
    allow(recipe).to receive(:config).and_return(double('Config').as_null_object)
    allow(FPM::Package::Dir).to receive(:new).and_return(fpm)
  end

  context '#package_input' do
    it 'calls the fpm package creation with a clean environment' do
      expect(fpm).to receive(:input).exactly(input.length).times

      package # Trigger object creation and package_input call.
    end
  end
end
