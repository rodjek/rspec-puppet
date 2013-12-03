require 'spec_helper'

describe 'testhost' do
  it { should contain_class('sysctl::common') }
end
