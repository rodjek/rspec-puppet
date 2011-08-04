require 'spec_helper'

describe 'sysctl::common' do
  it { should contain_exec('sysctl/reload') \
    .with_command('/sbin/sysctl -p /etc/sysctl.conf').with_returns([0, 2]) }
  it { should_not create_augeas('foo') }
end

describe 'sysctl::common' do
  let(:params) { { :test_param => "yes" } }

  it { should create_class("sysctl::common")\
    .with_test_param("yes") }
end
