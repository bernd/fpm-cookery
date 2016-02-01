require 'spec_helper'
require 'fpm/cookery/hiera'
require 'hiera/fpm_cookery_logger'

describe 'Hiera' do
  describe 'Defaults' do
    subject { FPM::Cookery::Hiera::Defaults }

    describe '.hiera_logger' do
      it 'provides a default logger key for Hiera' do
        expect(subject.hiera_logger).to eq 'fpm_cookery'
      end
    end

    describe '.hiera_hierarchy' do
      it 'provides a default lookup hierarchy for Hiera' do
        expect(subject.hiera_hierarchy).to contain_exactly(*[ENV['FPM_ENV'], '%{platform}', 'common'].compact)
      end
    end

    describe '.hiera_backends' do
      it 'provides a default backend list for Hiera' do
        expect(subject.hiera_backends).to contain_exactly(:yaml, :json)
      end
    end
  end

  describe 'Fpm_cookery_logger' do
    it 'aliases Hiera::Fpm_cookery_logger to FPM::Cookery::Log::Hiera' do
      expect(Object.const_get("Hiera::Fpm_cookery_logger")).to be (FPM::Cookery::Log::Hiera)
    end
  end

  describe 'Scope' do
    # Stubbed
    subject { FPM::Cookery::Scope.new({}) }
    describe '[]' do

    end
  end
end
