# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::RawString do
  subject(:raw_string) { described_class.new('some string') }

  describe '#inspect' do
    it 'returns an unquoted version of the string' do
      expect(raw_string.inspect).to eq('some string')
    end
  end
end
