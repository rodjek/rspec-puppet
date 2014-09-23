require 'spec_helper'

describe 'testhost' do
  it { should contain_class('sysctl::common') }

  describe 'testhost_a' do
    let(:node) { 'testhost_a' }
    it { should_not contain_class('sysctl::common') }
    it { should contain_file('/tmp/a') }
  end
end
