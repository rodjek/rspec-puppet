require 'spec_helper'

describe 'testhost' do
  it { is_expected.to contain_class('sysctl::common') }

  describe 'testhost_a' do
    let(:node) { 'testhost_a' }
    it { is_expected.to_not contain_class('sysctl::common') }
    it { is_expected.to contain_file('/tmp/a') }
  end
end
