require 'spec_helper'

describe 'sysctl' do
  let(:title) { 'vm.swappiness' }
  let(:params) { {:value => '60'} }

  describe 'rspec group' do
    it 'should have a catalogue method' do
      catalogue.should be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      subject.should be_a(Puppet::Resource::Catalog)
    end
  end
end
