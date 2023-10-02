# frozen_string_literal: true

require 'spec_helper'

describe 'test::basic' do
  it { is_expected.to contain_fake('foo').with_three([{ 'foo' => 'bar' }]) }

  context 'testing node based facts' do
    let(:pre_condition) { 'notify { $::fqdn: }' }
    let(:node) { 'test123.test.com' }
    let(:facts) do
      {
        fqdn: 'notthis.test.com',
        networking: {
          primary: 'eth0'
        }
      }
    end

    it { is_expected.to contain_notify('test123.test.com') }
    it { is_expected.not_to contain_notify('notthis.test.com') }

    context 'existing networking facts should not be clobbered' do
      let(:pre_condition) { 'notify { [$facts["networking"]["primary"], $facts["networking"]["hostname"]]: }' }

      it { is_expected.to contain_notify('eth0') }
      it { is_expected.to contain_notify('test123') }
    end

    context 'when derive_node_facts_from_nodename => false' do
      let(:pre_condition) { 'notify { $::fqdn: }' }
      let(:node) { 'mycertname.test.com' }
      let(:facts) do
        {
          fqdn: 'myhostname.test.com'
        }
      end

      before do
        RSpec.configuration.derive_node_facts_from_nodename = false
      end

      it { is_expected.to contain_notify('myhostname.test.com') }
      it { is_expected.not_to contain_notify('mycertname.test.com') }
    end
  end
end
