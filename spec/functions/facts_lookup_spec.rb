require 'rspec-puppet'

describe 'structured_facts::lookup', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 do
  context 'with one set of values' do
    let(:facts) {{ 'os' => {'family' => 'RedHat'} }}

    it { is_expected.to run.and_return('RedHat') }
  end

  context 'with a different set of values' do
    let(:facts) {{ 'os' => {'family' => 'Suse'} }}

    it { is_expected.to run.and_return('Suse') }
  end
end
