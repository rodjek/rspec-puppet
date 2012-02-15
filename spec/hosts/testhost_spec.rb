require 'spec_helper'

describe 'testhost' do
  it { should include_class('sysctl::common') }
end
