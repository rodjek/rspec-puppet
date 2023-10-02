# frozen_string_literal: true

require 'spec_helper'

family = 'RedHat'

# The current behavior is to convert a fact name to lower case.  An issue, FACT-777, has been submitted as a bug
# with the description of "Facter should not downcast fact names".  The "mixed case in facts" tests this functionality.

describe 'structured_facts::hash' do
  context 'symbols and strings in facts' do
    let(:facts) do
      {
        os: {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::hash') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  context 'only symbols in facts' do
    let(:facts) do
      {
        os: {
          family: family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::hash') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case symbols in facts' do
    let(:facts) do
      {
        oS: {
          family: family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::hash') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  context 'only strings in facts' do
    let(:facts) do
      {
        'os' => {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::hash') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case strings in facts' do
    let(:facts) do
      {
        'oS' => {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::hash') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end
end

describe 'structured_facts::top_scope' do
  context 'symbols and strings in facts' do
    let(:facts) do
      {
        os: {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::top_scope') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  context 'only symbols in facts' do
    let(:facts) do
      {
        os: {
          family: family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::top_scope') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case in facts' do
    let(:facts) do
      {
        Os: {
          family: family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::top_scope') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  context 'only string in facts' do
    let(:facts) do
      {
        'os' => {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::top_scope') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end

  # See note concerning mixed case in facts at the beginning of the file
  context 'mixed case in facts' do
    let(:facts) do
      {
        'Os' => {
          'family' => family
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::top_scope') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify(family) }
  end
end

describe 'structured_facts::case_check' do
  context 'mixed case in structure fact nested keys' do
    let(:facts) do
      {
        'custom_fact' => {
          'MixedCase' => 'value'
        }
      }
    end

    it { is_expected.to contain_class('structured_facts::case_check') }
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_notify('value') }
  end
end
