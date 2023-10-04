# frozen_string_literal: true

require 'spec_helper'

describe 'trusted_external_data' do
  context 'no trusted external data' do
    it { is_expected.to contain_class('trusted_external_data') }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_notify('no-external-data') }
  end

  context 'with trusted external data' do
    external_data = { foo_key: 'foo_value', bar_key: 'bar_value' }
    let(:trusted_external_data) do
      external_data
    end

    it { is_expected.to contain_class('trusted_external_data') }
    it { is_expected.to compile.with_all_deps }

    external_data.each do |k, v|
      it { is_expected.to contain_notify("external-#{k}-#{v}") }
    end
  end
end
