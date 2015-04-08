require 'spec_helper'

describe 'facts.acme.com' do
  it { should contain_file('environment').with_path('production') }
  it { should contain_file('clientversion').with_path(Puppet::PUPPETVERSION) }
  it { should contain_file('fqdn').with_path('facts.acme.com') }
  it { should contain_file('hostname').with_path('facts') }
  it { should contain_file('domain').with_path('acme.com') }
  it { should contain_file('clientcert').with_path('cert facts.acme.com') }
end
