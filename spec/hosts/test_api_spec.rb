# frozen_string_literal: true

require 'spec_helper'

describe 'foo.example.com' do
  describe 'rspec group' do
    it 'has a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      expect(subject.call).to be_a(Puppet::Resource::Catalog)
    end

    it 'has resources in its coverage report' do
      expect(RSpec::Puppet::Coverage.instance.results[:total]).to be > 0
      expect(RSpec::Puppet::Coverage.instance.results[:resources]).to include('Notify[test]')
    end
  end
end
