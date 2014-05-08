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
    it 'sets Puppet[:ordering] to "title-hash" by default' do
      subject.setup_puppet
      expect(Puppet[:ordering]).to eq("title-hash")
    end
    it 'reads the :parser setting' do
      allow(subject).to receive(:parser).and_return("future")
      subject.setup_puppet
      expect(Puppet[:parser]).to eq("future")
    end
    it 'reads the :ordering setting' do
      allow(subject).to receive(:ordering).and_return("random")
      subject.setup_puppet
      expect(Puppet[:ordering]).to eq("random")
    end
  end
end
