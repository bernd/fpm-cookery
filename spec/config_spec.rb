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

      config.__send__(name).must_equal '__set__'
    end

    it 'can be set' do
      config.__send__("#{name}=", '__SET__')
      config.__send__(name).must_equal '__SET__'
    end

    it 'provides a ? method' do
      data[name.to_sym] = false

      config.__send__("#{name}?").must_equal false
    end
  end

  describe '#color' do
    it 'defaults to true' do
      default_config.color.must_equal true
    end

    common_tests(:color)
  end

  describe '#debug' do
    it 'defaults to true' do
      default_config.debug.must_equal false
    end

    common_tests(:debug)
  end

  describe '#target' do
    it 'defaults to nil' do
      default_config.target.must_equal nil
    end

    common_tests(:target)
  end

  describe '#platform' do
    it 'defaults to nil' do
      default_config.platform.must_equal nil
    end

    common_tests(:platform)
  end

  describe '#maintainer' do
    it 'defaults to nil' do
      default_config.maintainer.must_equal nil
    end

    common_tests(:maintainer)
  end

  describe '#vendor' do
    it 'defaults to nil' do
      default_config.vendor.must_equal nil
    end

    common_tests(:vendor)
  end

  describe '#skip_package' do
    it 'defaults to false' do
      default_config.skip_package.must_equal false
    end

    common_tests(:skip_package)
  end

  describe '#keep_destdir' do
    it 'defaults to false' do
      default_config.keep_destdir.must_equal false
    end

    common_tests(:keep_destdir)
  end

  describe '#dependency_check' do
    it 'defaults to false' do
      default_config.dependency_check.must_equal true
    end

    common_tests(:dependency_check)
  end

  describe '#to_hash' do
    it 'returns a hash representation of the object' do
      default_config.to_hash.must_equal({
        :color => true,
        :debug => false,
        :target => nil,
        :platform => nil,
        :maintainer => nil,
        :vendor => nil,
        :skip_package => false,
        :keep_destdir => false,
        :dependency_check => true
      })
    end
  end

  describe 'with an invalid config key' do
    it 'raises an error' do
      data[:__foo__] = true

      proc { config }.must_raise FPM::Cookery::Error::InvalidConfigKey
    end

    it 'adds the invalid keys' do
      data[:__foo__] = true
      data[:__bar__] = true
      error = nil

      begin; config; rescue => e; error = e; end

      error.invalid_keys.must_equal [:__foo__, :__bar__]
    end

    it 'works with strings' do
      data['maintainer'] = 'John'

      config.maintainer.must_equal 'John'
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

      config.maintainer.must_equal 'John Doe <john@example.com>'
    end
  end

  describe '.from_cli' do
    it 'loads the config from cli options' do
      cli = FPM::Cookery::CLI.new('path', {})
      cli.parse(%w(-D -t rpm))

      config = FPM::Cookery::Config.from_cli(cli)

      config.debug.must_equal true
      config.target.must_equal 'rpm'
    end
  end
end
