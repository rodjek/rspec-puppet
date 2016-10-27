require 'spec_helper'

describe 'test::bare_class' do
  describe 'rspec group' do
    it 'should have a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      expect(subject.call).to be_a(Puppet::Resource::Catalog)
    end

    describe 'derivative group' do
      subject { catalogue.resource('Notify', 'foo') }

      it 'can redefine subject' do
        expect(subject).to be_a(Puppet::Resource)
      end
    end
  end
end
