require 'spec_helper'

describe RSpec::Puppet::Support do
  subject do
    klass = Class.new do
      include RSpec::Puppet::Support
    end
    klass.new
  end

  describe '#setup_puppet' do
    it 'sets Puppet[:parser] to "current" by default', :unless => Puppet.version.to_f >= 4.0 do
      subject.setup_puppet
      expect(Puppet[:parser]).to eq("current")
    end
    it 'reads the :parser setting', :unless => Puppet.version.to_f >= 4.0 do
      allow(subject).to receive(:parser).and_return("future")
      subject.setup_puppet
      expect(Puppet[:parser]).to eq("future")
    end
    it 'updates the ruby $LOAD_PATH based on the current modulepath' do
      basedir = '/mymodulepath'
      RSpec.configuration.module_path = basedir

      dira = File.join(basedir, 'a', 'lib')
      dirb = File.join(basedir, 'b', 'lib')
      allow(Dir).to receive(:[]).with("#{basedir}/*/lib").and_return([dira, dirb])

      subject.setup_puppet

      expect($LOAD_PATH).to include(dira)
      expect($LOAD_PATH).to include(dirb)
    end
  end
end
