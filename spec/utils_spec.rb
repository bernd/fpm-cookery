require 'spec_helper'
require 'fpm/cookery/utils'

describe FPM::Cookery::Utils do
  class TestUtils
    include FPM::Cookery::Utils

    def run_configure_no_arg
      configure
    end
  end

  let(:test) { TestUtils.new }

  before do
    # Avoid shellout.
    allow(test).to receive(:system).and_return('success')
  end

  describe '#configure' do
    context 'without any arguments' do
      it 'calls ./configure without any arguments' do
        expect(test).to receive(:system).with('./configure')
        test.run_configure_no_arg
      end
    end
  end
end
