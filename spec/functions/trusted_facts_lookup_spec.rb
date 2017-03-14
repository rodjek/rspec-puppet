require 'spec_helper'

describe 'trusted_facts::lookup', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 do
  let(:node) { 'trusted.example.com' }

  context 'without trusted fact extensions' do
    it { is_expected.to run.with_params('certname').and_return(node) }
    it { is_expected.to run.with_params('hostname').and_return('trusted') }
    it { is_expected.to run.with_params('domain').and_return('example.com') }
    it { is_expected.to run.with_params('authenticated').and_return('remote') }
    it { is_expected.to run.with_params('extensions').and_return({}) }
  end

  context 'with trusted fact extensions' do
    let(:trusted_facts) {{
      'extra1' => '1',
      'extra2' => '2'
    }}

    it { is_expected.to run.with_params('extensions').and_return(trusted_facts) }
  end
end
