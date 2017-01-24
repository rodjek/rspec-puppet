require 'spec_helper'
require 'rspec-puppet/adapters'

describe RSpec::Puppet::Support do
  subject do
    Object.new.extend(RSpec::Puppet::Support)
  end

  describe '#setup_puppet' do
    before do
      adapter = RSpec::Puppet::Adapters.get
      adapter.setup_puppet(subject)
      subject.adapter = adapter
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

  describe "#ref" do
    it 'should return a new RawString with the type/title format' do
      expect(subject.ref('Package','tomcat').inspect).to eq("Package['tomcat']")
    end
  end

  describe '#str_from_value' do
    it "should quote strings" do
      expect(subject.str_from_value('a string')).to eq('"a string"')
    end
    it "should not quote numbers" do
      expect(subject.str_from_value(100)).to eq('100')
      expect(subject.str_from_value(-42)).to eq('-42')
      expect(subject.str_from_value(3.14)).to eq('3.14')
    end
    it "should use literal 'default' when receiving :default" do
      expect(subject.str_from_value(:default)).to eq('default')
    end
    it "should use literal 'undef' when receiving :undef" do
      expect(subject.str_from_value(:undef)).to eq('undef')
    end
    it "should convert Symbols to Strings" do
      expect(subject.str_from_value(:a_symbol)).to eq('"a_symbol"')
    end
    it "should handle Arrays recursively" do
      expect(subject.str_from_value([1,2,3])).to eq('[ 1, 2, 3 ]')
    end
    it "should handle Hashes recursively" do
      expect(subject.str_from_value({:k1=>'v1'})).to eq('{ "k1" => "v1" }')
      expect(subject.str_from_value({'k2'=>'v2'})).to eq('{ "k2" => "v2" }')
      expect(subject.str_from_value({k3: 'v3'})).to eq('{ "k3" => "v3" }')
    end
  end
end
