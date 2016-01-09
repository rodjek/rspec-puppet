require 'spec_helper'
require 'rspec-puppet/adapters'

describe RSpec::Puppet::Support do
  subject do
    Object.new.extend(RSpec::Puppet::Support)
  end

  describe '#setup_puppet' do
    before do
      RSpec::Puppet::Adapters.get.setup_puppet(subject)
    end

    it 'updates the ruby $LOAD_PATH based on the current modulepath' do
      basedir = RSpec.configuration.module_path

      dira = File.join(basedir, 'a', 'lib')
      dirb = File.join(basedir, 'b', 'lib')
      allow(Dir).to receive(:[]).with("#{basedir}/*/lib").and_return([dira, dirb])

      subject.setup_puppet

      expect($LOAD_PATH).to include(dira)
      expect($LOAD_PATH).to include(dirb)
    end
  end
end
