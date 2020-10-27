require 'spec_helper'

describe 'trusted_external_data', :if => Puppet::Util::Package.versioncmp(Puppet.version, '6.14.0') >= 0 do
  context 'no trusted external data' do
    it { should contain_class('trusted_external_data') }
    it { should compile.with_all_deps }
    it { should contain_notify("no-external-data") }
  end

  context 'with trusted external data' do
    external_data = {:foo_key => "foo_value", :bar_key => "bar_value"}
    let(:trusted_external_data) do
      external_data
    end

    it { should contain_class('trusted_external_data') }
    it { should compile.with_all_deps }
    external_data.each do |k,v|
      it { should contain_notify("external-#{k}-#{v}") }
    end
  end
end
