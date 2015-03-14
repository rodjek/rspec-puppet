require 'spec_helper'

describe RSpec::Puppet::Support do
  subject do
    klass = Class.new do
      include RSpec::Puppet::Support
    end
    klass.new
  end

  describe '#setup_puppet' do
    it 'sets Puppet[:parser] to "current" by default' do
      subject.setup_puppet
      expect(Puppet[:parser]).to eq("current")
    end
    it 'reads the :parser setting' do
      allow(subject).to receive(:parser).and_return("future")
      subject.setup_puppet
      expect(Puppet[:parser]).to eq("future")
    end
    it 'sets Puppet[:strict_variables] to false by default' do
      subject.setup_puppet
      expect(Puppet[:strict_variables]).to eq(false)
    end
    it 'reads the :strict_variables setting' do
      allow(subject).to receive(:strict_variables).and_return(true)
      subject.setup_puppet
      expect(Puppet[:strict_variables]).to eq(true)
    end
  end
end
