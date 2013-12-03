require 'spec_helper'

describe 'foo.example.com' do
  it { should_not contain_class('sysctl::common') }
  it { should contain_notify('test') }
end
