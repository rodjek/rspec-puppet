# frozen_string_literal: true

require 'spec_helper'

describe 'facts.acme.com' do
  it { is_expected.to contain_file('environment').with_path('rp_env') }
  it { is_expected.to contain_file('clientversion').with_path(Puppet::PUPPETVERSION) }
  it { is_expected.to contain_file('fqdn').with_path('facts.acme.com') }
  it { is_expected.to contain_file('hostname').with_path('facts') }
  it { is_expected.to contain_file('domain').with_path('acme.com') }
  it { is_expected.to contain_file('clientcert').with_path('cert facts.acme.com') }
end
