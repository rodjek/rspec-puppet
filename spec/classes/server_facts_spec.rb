require 'spec_helper'

describe 'server_facts', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 do

  context 'with server_facts' do
    before do
      RSpec.configuration.trusted_server_facts = true
    end

    let(:facts) {
      {
        :ipaddress => '192.168.1.10'
      }
    }
    let(:node) { 'test123.test.com' }
    it { should contain_class('server_facts') }
    it { should compile.with_all_deps }
    it { should contain_notify("servername-test123.test.com") }
    it { should contain_notify("serverip-192.168.1.10") }
    it { should contain_notify("serverversion-#{Puppet.version}") }
    it { should contain_notify("environment-rp_env") }
  end
end
