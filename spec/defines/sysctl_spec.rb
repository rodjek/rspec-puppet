require 'spec_helper'

describe 'sysctl' do
  let(:title) { 'vm.swappiness' }
  let(:params) { {:value => '60'} }

  it { should include_class('sysctl::common') }
  it { should create_augeas('sysctl/vm.swappiness') \
    .with_context('/files/etc/sysctl.conf') \
    .with_changes("set vm.swappiness '60'") \
    .with_onlyif("match vm.swappiness[.='60'] size == 0") \
    .with_notify('Exec[sysctl/reload]')\
    .without_foo }
end
