require 'spec_helper'

describe 'foo.example.com' do
  describe 'rspec group' do
    it 'should have a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      expect(subject).to be_a(Puppet::Resource::Catalog)
    end
  end
end
