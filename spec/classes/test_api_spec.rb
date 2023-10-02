# frozen_string_literal: true

require 'spec_helper'

describe 'test::bare_class' do
  describe 'rspec group' do
    it 'has a catalogue method' do
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

  describe 'coverage' do
    it 'class should be included in the coverage filter' do
      expect(RSpec::Puppet::Coverage.filters).to include('Class[Test::Bare_class]')
    end

    it 'does not include resources from other modules created with create_resources()' do
      expect(RSpec::Puppet::Coverage.instance.results[:resources]).not_to include('Notify[create_resources notify]')
      expect(subject).to contain_notify('create_resources notify')
    end
  end
end
