require 'spec_helper'

nodoublequotes = Proc.new do |x|
  not x =~ /"/
end

describe 'sysctl' do
  let(:title) { 'vm.swappiness' }
  let(:params) { {:value => '60'} }
  let(:pre_condition) { }

  it { is_expected.to contain_class('sysctl::common') }
  it { is_expected.to create_augeas('sysctl/vm.swappiness') \
    .with_context('/files/etc/sysctl.conf') \
    .with_changes("set vm.swappiness '60'") \
    .with_changes(nodoublequotes) \
    .with_onlyif("match vm.swappiness[.='60'] size == 0") \
    .with_notify('Exec[sysctl/reload]')\
    .without_foo }
  it { is_expected.to have_sysctl_resource_count(1) }
end
