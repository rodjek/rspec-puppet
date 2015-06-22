require 'spec_helper'

# hiera is not supported before 2.7
describe 'test::hiera', :if => Puppet.version.to_f >= 3.0 do
  context 'with :hiera_config set' do
    let(:hiera_config) { 'spec/fixtures/hiera.yaml' }
    it { should contain_notify('foo') }
  end

  context 'without :hiera_config set' do
    it { should contain_notify('not found') }
  end
end

