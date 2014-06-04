require 'spec_helper'

describe 'foo.example.com' do
  it { is_expected.not_to contain_class('sysctl::common') }
  it { is_expected.to contain_notify('test') }
end
