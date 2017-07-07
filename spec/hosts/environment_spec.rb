require 'spec_helper'

describe 'facts.acme.com' do
  context 'without an explicit environment setting' do
    it { should contain_file('environment').with_path('rp_env') }
  end
  # Broken on ~> 3.8.5 since PUP-5522
  context 'when specifying an explicit environment', :unless => (Puppet.version >= '3.8.5' && Puppet.version.to_i < 4) do
    let(:environment) { 'test_env' }
    it { should contain_file('environment').with_path('test_env') }
    it { should contain_file('conditional_file') }
  end

  context 'test' do
    let(:environment) { :production }
    it { should contain_file('environment').with_path('production') }
  end
end
