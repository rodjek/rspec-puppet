# frozen_string_literal: true

require 'spec_helper'

describe 'trusted_facts' do
  context 'FQDN as certname' do
    let(:node) { 'trusted.example.com' }

    it { is_expected.to contain_class('trusted_facts') }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_notify("certname-#{node}") }
    it { is_expected.to contain_notify('authenticated-remote') }
    it { is_expected.to contain_notify('hostname-trusted') }
    it { is_expected.to contain_notify('domain-example.com') }
    it { is_expected.to contain_notify('no-extensions') }
  end

  context 'shortname as certname' do
    let(:node) { 'trusted' }

    it { is_expected.to contain_class('trusted_facts') }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_notify("certname-#{node}") }
    it { is_expected.to contain_notify('authenticated-remote') }
    it { is_expected.to contain_notify('hostname-trusted') }
    it { is_expected.to contain_notify('domain-') }
    it { is_expected.to contain_notify('no-extensions') }
  end

  context 'with extensions' do
    extensions = {
      :pp_uuid => 'ED803750-E3C7-44F5-BB08-41A04433FE2E',
      '1.3.6.1.4.1.34380.1.2.1' => 'ssl-termination'
    }
    let(:trusted_facts) { extensions }
    let(:node) { 'trusted.example.com' }

    it { is_expected.to contain_class('trusted_facts') }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_notify("certname-#{node}") }
    it { is_expected.to contain_notify('authenticated-remote') }
    it { is_expected.to contain_notify('hostname-trusted') }
    it { is_expected.to contain_notify('domain-example.com') }
    it { is_expected.not_to contain_notify('no-extensions') }

    extensions.each do |k, v|
      it { is_expected.to contain_notify("extension-#{k}-#{v}") }
    end
  end
end
