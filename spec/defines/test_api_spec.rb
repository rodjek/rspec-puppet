# frozen_string_literal: true

require 'spec_helper'

describe 'sysctl' do
  let(:title) { 'vm.swappiness' }
  let(:params) { { value: '60' } }

  describe 'rspec group' do
    it 'has a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      expect(subject.call).to be_a(Puppet::Resource::Catalog)
    end

    it 'is included in the coverage filter' do
      expect(RSpec::Puppet::Coverage.filters).to include('Sysctl[vm.swappiness]')
    end
  end
end
