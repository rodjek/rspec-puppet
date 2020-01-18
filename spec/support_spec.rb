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

  describe "#sensitive" do
    context 'when using a version of Puppet that supports the Sensitive type', :if => sensitive? do
      it 'should return a new Sensitive with the given contents' do
        sens = subject.sensitive('test content')
        expect(sens).to be_sensitive
        expect(sens.unwrap).to eq 'test content'
      end
    end

    context 'when using a version of Puppet that does not support Sensitive', :unless => sensitive? do
      it 'should raise an error' do
        expect { subject.sensitive('test content') }.to raise_error
      end
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
    end
  end

  describe '#find_pretend_platform' do
    let(:build_hash) do
      {
	"hostname" => "fy73bdiqazmyj62",
	"networking" => {
	  "hostname" => "fy73bdiqazmyj62",
	  "fqdn" => "fy73bdiqazmyj62.delivery.puppetlabs.net"
	},
      }
    end
    context 'without os facts' do
      it 'returns the correct platform' do
	expect(subject.find_pretend_platform(build_hash)).to eq(nil)
      end
    end
    { 'windows' => :windows, 'debian' => :posix }.each do |family, platform|
      context 'with os structured fact' do
	let(:build_hash) do
	  super().merge({
	    "os" => {
	      "family" => family,
	      "version" => {
		"major" => "10"
	      }
	    }
	  })
	end
	it 'returns the correct platform' do
	  expect(subject.find_pretend_platform(build_hash)).to eq(platform)
	end
      end
      context 'with osfamily fact' do
	let(:build_hash) do
	  super().merge({
	    "osfamily" => family
	  })
	end
	it 'returns the correct platform' do
	  expect(subject.find_pretend_platform(build_hash)).to eq(platform)
	end
      end
    end
  end

  describe '#build_code' do
    before do
      class << subject
        def class_name
          "class_name"
        end
        def site_pp_str
          ""
        end
        def import_str
          ""
        end
      end
    end

    context "without any properties" do
      it "builds a test manifest" do
        expect(subject.build_code(:class, {})).to eq "\ninclude class_name"
      end
    end

    context "with a pre_condition available" do
      before do
        class << subject
          def pre_condition
            "pre_condition"
          end
        end
      end

      it "builds a test manifest" do
        expect(subject.build_code(:class, {})).to eq "\npre_condition\ninclude class_name"
      end
    end

    context "with a post_condition available" do
      before do
        class << subject
          def post_condition
            "post_condition"
          end
        end
      end

      it "builds a test manifest" do
        expect(subject.build_code(:class, {})).to eq "\ninclude class_name\npost_condition"
      end
    end
  end
end
