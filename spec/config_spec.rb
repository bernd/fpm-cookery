require 'spec_helper'
require 'fpm/cookery/config'
require 'fpm/cookery/cli'

describe 'Config' do
  let(:data) { {} }
  let(:default_config) { FPM::Cookery::Config.new }
  let(:config) { FPM::Cookery::Config.new(data) }

  def self.common_tests(name)
    it 'can be set on init' do
      data[name.to_sym] = '__set__'

      expect(config.__send__(name)).to eq('__set__')
    end

    it 'can be set' do
      config.__send__("#{name}=", '__SET__')

      expect(config.__send__(name)).to eq('__SET__')
    end

    it 'provides a ? method' do
      data[name.to_sym] = false

      expect(config.__send__("#{name}?")).to eq(false)
    end
  end

  describe '#color' do
    it 'defaults to true' do
      expect(default_config.color).to eq(true)
    end

    common_tests(:color)
  end

  describe '#debug' do
    it 'defaults to true' do
      expect(default_config.debug).to eq(false)
    end

    common_tests(:debug)
  end

  describe '#target' do
    it 'defaults to nil' do
      expect(default_config.target).to eq(nil)
    end

    common_tests(:target)
  end

  describe '#platform' do
    it 'defaults to nil' do
      expect(default_config.platform).to eq(nil)
    end

    common_tests(:platform)
  end

  describe '#maintainer' do
    it 'defaults to nil' do
      expect(default_config.maintainer).to eq(nil)
    end

    common_tests(:maintainer)
  end

  describe '#vendor' do
    it 'defaults to nil' do
      expect(default_config.vendor).to eq(nil)
    end

    common_tests(:vendor)
  end

  describe '#quiet' do
    it 'defaults to false' do
      expect(default_config.quiet).to eq(false)
    end

    common_tests(:quiet)
  end

  describe '#skip_package' do
    it 'defaults to false' do
      expect(default_config.skip_package).to eq(false)
    end

    common_tests(:skip_package)
  end

  describe '#keep_destdir' do
    it 'defaults to false' do
      expect(default_config.keep_destdir).to eq(false)
    end

    common_tests(:keep_destdir)
  end

  describe '#dependency_check' do
    it 'defaults to false' do
      expect(default_config.dependency_check).to eq(true)
    end

    common_tests(:dependency_check)
  end

  describe '#tmp_root' do
    it 'defaults to nil' do
      expect(default_config.tmp_root).to be_nil
    end

    common_tests(:tmp_root)
  end

  describe '#pkg_dir' do
    it 'defaults to nil' do
      expect(default_config.pkg_dir).to be_nil
    end

    common_tests(:pkg_dir)
  end

  describe '#cache_dir' do
    it 'defaults to nil' do
      expect(default_config.cache_dir).to be_nil
    end

    common_tests(:cache_dir)
  end

  describe '#to_hash' do
    it 'returns a hash representation of the object' do
      expect(default_config.to_hash).to eq({
        :color => true,
        :debug => false,
        :target => nil,
        :platform => nil,
        :maintainer => nil,
        :tmp_root => nil,
        :pkg_dir => nil,
        :cache_dir => nil,
        :vendor => nil,
        :skip_package => false,
        :keep_destdir => false,
        :dependency_check => true,
        :quiet => false
      })
    end
  end

  describe 'with an invalid config key' do
    it 'raises an error' do
      data[:__foo__] = true

      expect { config }.to raise_error(FPM::Cookery::Error::InvalidConfigKey)
    end

    it 'adds the invalid keys' do
      data[:__foo__] = true
      data[:__bar__] = true
      error = nil

      begin; config; rescue => e; error = e; end

      # Sort array for Ruby 1.8.7 compat.
      expect(error.invalid_keys.sort).to eq([:__bar__, :__foo__])
    end

    it 'works with strings' do
      data['maintainer'] = 'John'

      expect(config.maintainer).to eq('John')
    end
  end

  describe '.load_file' do
    let(:paths) do
      [
        '/tmp/__abc__',
        File.expand_path('../fixtures/test-config-1.yml', __FILE__)
      ]
    end

    it 'loads first found file' do
      config = FPM::Cookery::Config.load_file(paths)

      expect(config.maintainer).to eq('John Doe <john@example.com>')
    end
  end

  describe '.from_cli' do
    it 'loads the config from cli options' do
      cli = FPM::Cookery::CLI.new('path', {})
      cli.parse(%w(-D -t rpm))

      config = FPM::Cookery::Config.from_cli(cli)

      expect(config.debug).to eq(true)
      expect(config.target).to eq('rpm')
    end
  end
end
