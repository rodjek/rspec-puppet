require 'spec_helper'

describe 'facts.acme.com' do
  context 'without an explicit environment setting' do
    it { should contain_file('environment').with_path('rp_env') }
  end
  context 'when specifying an explicit environment' do
    let(:environment) { 'test_env' }
    it { should contain_file('environment').with_path('test_env') }
  end
end
