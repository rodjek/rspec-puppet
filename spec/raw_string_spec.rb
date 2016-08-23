require 'rspec-puppet/raw_string'

describe RSpec::Puppet::RawString do
  describe '#inspect' do
    it 'returns the raw string when doing an inspect' do
      expect(RSpec::Puppet::RawString.new('my_raw_string').inspect).to eq('my_raw_string')
    end
  end
end
