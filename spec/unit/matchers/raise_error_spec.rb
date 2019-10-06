require 'spec_helper'
require 'rspec-puppet/support'

describe RSpec::Puppet::GenericMatchers::RaiseError do
  include RSpec::Puppet::GenericMatchers

  context 'with a failing target' do
    subject { lambda { fail 'catalogue load failed' } }

    it { should raise_error 'catalogue load failed' }
  end

  context 'with a passing target' do
    subject { lambda { } }

    it { should_not raise_error }
  end
end
