# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/sensitive'

describe RSpec::Puppet::Sensitive do
  subject(:sensitive) { described_class.new contents }

  let(:contents) { double :contents }

  describe '#sensitive?' do
    it 'returns true' do
      expect(sensitive).to be_sensitive
    end
  end

  describe '#unwrap' do
    it 'returns the wrapped value' do
      expect(sensitive.unwrap).to eq contents
    end
  end

  describe '#inspect' do
    it 'wraps the contents in Sensitive()' do
      expect(sensitive.inspect).to eq "Sensitive(#{contents.inspect})"
    end
  end

  describe '#==' do
    it 'compares equal to Puppet sensitive type' do
      expect(sensitive).to eq Puppet::Pops::Types::PSensitiveType::Sensitive.new contents
    end

    it 'compares false to the unwrapped value' do
      expect(sensitive).not_to eq(contents)
    end
  end
end
