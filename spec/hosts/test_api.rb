require 'spec_helper'

describe 'foo.example.com' do
  describe 'rspec group' do
    it 'should have a catalogue method' do
      catalogue.should be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      subject.should be_a(Puppet::Resource::Catalog)
    end
  end
end
