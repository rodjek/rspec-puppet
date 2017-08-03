require 'spec_helper'

describe 'trusted_facts', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 do
  context 'without node set' do
    it { should contain_class('trusted_facts') }
    it { should compile.with_all_deps }
    it { should contain_notify("certname-my_node.my_node") }
    it { should contain_notify("authenticated-remote") }
    it { should contain_notify("hostname-my_node") }
    it { should contain_notify("domain-my_node") }
    it { should contain_notify("no-extensions") }
  end

  context 'FQDN as certname' do
    let(:node) { 'trusted.example.com' }
    it { should contain_class('trusted_facts') }
    it { should compile.with_all_deps }
    it { should contain_notify("certname-#{node}") }
    it { should contain_notify("authenticated-remote") }
    it { should contain_notify("hostname-trusted") }
    it { should contain_notify("domain-example.com") }
    it { should contain_notify("no-extensions") }
  end

  context 'shortname as certname' do
    let(:node) { 'trusted' }

    it { should contain_class('trusted_facts') }
    it { should compile.with_all_deps }
    it { should contain_notify("certname-#{node}") }
    it { should contain_notify("authenticated-remote") }
    it { should contain_notify("hostname-trusted") }
    it { should contain_notify("domain-") }
    it { should contain_notify("no-extensions") }
  end

  context 'with extensions' do
    extensions = {
      :pp_uuid                  => 'ED803750-E3C7-44F5-BB08-41A04433FE2E',
      '1.3.6.1.4.1.34380.1.2.1' => 'ssl-termination'
    }
    let(:trusted_facts) { extensions }
    let(:node) { 'trusted.example.com' }

    it { should contain_class('trusted_facts') }
    it { should compile.with_all_deps }
    it { should contain_notify("certname-#{node}") }
    it { should contain_notify("authenticated-remote") }
    it { should contain_notify("hostname-trusted") }
    it { should contain_notify("domain-example.com") }
    it { should_not contain_notify("no-extensions") }
    extensions.each do |k,v|
      it { should contain_notify("extension-#{k}-#{v}") }
    end
  end
end
