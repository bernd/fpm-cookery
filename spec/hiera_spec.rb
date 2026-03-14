require 'spec_helper'
require 'fpm/cookery/book'
require 'fpm/cookery/book_hook'
require 'fpm/cookery/facts'
require 'fpm/cookery/hiera'
require 'fpm/cookery/recipe'
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
        expect(subject.hiera_hierarchy).to contain_exactly('common')
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
      expect(Hiera.const_get("Fpm_cookery_logger")).to be (FPM::Cookery::Log::Hiera)
    end
  end

  describe 'Scope' do
    let(:scope) { FPM::Cookery::Hiera::Scope.new(recipe) }
    include_context "recipe class", __FILE__, :platform => nil, :hiera_config => nil,
                                              :data_dir => fixture_path('hiera_config')

    describe '[]' do
      context 'given an argument corresponding to a recipe class method' do
        it 'returns the value returned by the class method' do
          expect(scope['workdir']).to eq(recipe.workdir)
        end
      end

      context 'given an argument corresponding to an FPM::Cookery::Fact class method' do
        it 'returns the value returned by the class method' do
          expect(scope['osmajorrelease']).to eq(FPM::Cookery::Facts.osmajorrelease)
        end
      end

      context 'given an otherwise unresolvable argument' do
        it 'returns nil' do
          expect(scope['nonexistent_key']).to be_nil
        end
      end
    end
  end

  describe '#lookup' do
    include_context "recipe class", __FILE__, :platform => nil, :hiera_config => nil,
                                              :data_dir => fixture_path('hiera_config')

    context "given default options and unset `platform' fact" do
      it "returns values from `common.yaml' only" do
        expect(recipe.lookup('environment')).to eq('PREFIX' => '/opt')
        expect(recipe.lookup('version')).to eq('1.0.2')
        expect(recipe.lookup('post_install')).to eq((recipe.workdir / 'default.sh').to_s)
      end
    end

    context 'given a platform' do
      before(:each) { allow(config).to receive(:platform).and_return('CentOS') }

      it "prefers values from `\#{platform}.yaml'" do
        expect(recipe.lookup('post_install')).to eq((recipe.workdir / 'fix_ldconfig.sh').to_s)
      end
    end

    context 'given a value for ENV["FPM_HIERARCHY"]' do
      around(:each) do |example|
        ENV['FPM_HIERARCHY'] = env
        example.run
        ENV.delete('FPM_HIERARCHY')
      end

      context 'that does not correspond to an existing data file' do
        let(:env) { 'fake' }

        it 'uses data from the default data file' do
          expect(recipe.lookup('environment')).to eq('PREFIX' => '/opt')
        end
      end

      context 'that corresponds to an existing data file' do
        let(:env) { 'custom' }

        it 'prefers data from that file' do
          expect(recipe.lookup('environment')).to eq('PREFIX' => '/usr/local', 'AUTOMATED_TESTING' => 1)
        end
      end
    end
  end

  describe "#new" do
    context "given a string as the option to `:config'" do
      let(:hiera) { FPM::Cookery::Hiera::Instance.new(recipe, :config => filename) }

      let(:recipe) do
        double('Recipe').as_null_object
      end

      context "that does not refer to an existing hiera.yaml file" do
        let(:filename) { "/probably/does/not/exist/pretty/sure/anyway" }

        it "raises an error when Hiera config file does not exist" do
          expect { hiera }.to raise_error(RuntimeError)
        end
      end

      context "that refers to an existing hiera.yaml file" do
        let(:filename) { 'hiera.yaml' }

        around(:each) do |example|
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              File.open(filename, 'w') do |config_file|
                config_file.print <<-CONFIG_FILE
                  :backends:
                    - json
                  :json:
                    :datadir: '/hey/i/am/a/datadir'
                  :hierarchy:
                    - yakko
                    - wakko
                    - dot
                CONFIG_FILE
              end

              example.run
            end
          end
        end

        it "loads settings from that file" do
          expect(hiera.config[:backends]).to contain_exactly('json')
          expect(hiera.config[:json]).to eq(:datadir => '/hey/i/am/a/datadir')
          expect(hiera.config[:hierarchy]).to contain_exactly(*%w{yakko wakko dot})
        end
      end
    end
  end
end
