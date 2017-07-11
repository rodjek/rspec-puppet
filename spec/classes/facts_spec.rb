require 'spec_helper'
require 'deep_merge'

family = 'RedHat'

# The current behavior is to convert a fact name to lower case.  An issue, FACT-777, has been submitted as a bug
# with the description of "Facter should not downcast fact names".  The "mixed case in facts" tests this functionality.

describe 'structured_facts::hash' do

  context 'symbols and strings in facts', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      :os => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::hash') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  context 'only symbols in facts', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      :os => {
        :family => family
      }
    }}

    it { should contain_class('structured_facts::hash') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case symbols in facts', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      :oS => {
        :family => family
      }
    }}

    it { should contain_class('structured_facts::hash') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  context 'only strings in facts', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      'os' => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::hash') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case strings in facts', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      'oS' => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::hash') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end
end

describe 'structured_facts::top_scope' do

  context 'symbols and strings in facts' do
    let(:facts) {{
      :os => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::top_scope') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  context 'only symbols in facts' do
    let(:facts) {{
      :os => {
        :family => family
      }
    }}

    it { should contain_class('structured_facts::top_scope') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case in facts' do
    let(:facts) {{
      :Os => {
        :family => family
      }
    }}

    it { should contain_class('structured_facts::top_scope') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  context 'only string in facts' do
    let(:facts) {{
      'os' => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::top_scope') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case in facts' do
    let(:facts) {{
      'Os' => {
        'family' => family
      }
    }}

    it { should contain_class('structured_facts::top_scope') }
    it { should compile.with_all_deps }

    it { should contain_notify(family) }
  end
end

describe 'structured_facts::case_check' do
  context 'mixed case in structure fact nested keys', :if => Puppet.version.to_f >= 4.0 do
    let(:facts) {{
      'custom_fact' => {
        'MixedCase' => 'value'
      }
    }}

    it { should contain_class('structured_facts::case_check') }
    it { should compile.with_all_deps }

    it { should contain_notify('value') }
  end
end

describe 'structured_facts::hostname' do
  let(:facts) { { networking: { other: 'foo' } } }
  let(:fqdn) { node }
  let(:hostname) { fqdn.split('.').first }
  let(:domain) { fqdn.split('.', 2).last }

  context 'when node => testnode.example.com' do
    let(:node) { 'testnode.example.com' }

    it { should contain_class('structured_facts::hostname') }
    it { should compile.with_all_deps }

    it { should contain_notify("clientcert:#{node}") }
    it { should contain_notify("hostname:#{hostname}") }
    it { should contain_notify("domain:#{domain}") }
    it { should contain_notify("fqdn:#{fqdn}") }
    it { should contain_notify("nh-hostname:#{hostname}") }
    it { should contain_notify("nh-domain:#{domain}") }
    it { should contain_notify("nh-fqdn:#{fqdn}") }
    it { should contain_notify('nh-other:foo') }
  end

  context 'when node => testnode.example.com with fqdn set in facts' do
    let(:node) { 'testnode' }
    let(:fqdn) { 'another.example.net' }
    let(:facts) { super().deep_merge(
      fqdn: fqdn,
      hostname: hostname,
      domain: domain,
      networking: {
        fqdn: fqdn,
        hostname: hostname,
        domain: domain,
      }
    ) }

    it { should contain_class('structured_facts::hostname') }
    it { should compile.with_all_deps }

    it { should contain_notify("clientcert:#{node}") }
    it { should contain_notify("hostname:#{hostname}") }
    it { should contain_notify("domain:#{domain}") }
    it { should contain_notify("fqdn:#{fqdn}") }
    it { should contain_notify("nh-hostname:#{hostname}") }
    it { should contain_notify("nh-domain:#{domain}") }
    it { should contain_notify("nh-fqdn:#{fqdn}") }
    it { should contain_notify('nh-other:foo') }
  end
end
