# frozen_string_literal: true

require 'spec_helper'

describe 'facts.acme.com' do
  context 'without an explicit environment setting' do
    it { is_expected.to contain_file('environment').with_path('rp_env') }
  end

  context 'when specifying an explicit environment' do
    let(:environment) { 'test_env' }

    it { is_expected.to contain_file('environment').with_path('test_env') }
    it { is_expected.to contain_file('conditional_file') }
  end

  context 'test' do
    let(:environment) { :production }

    it { is_expected.to contain_file('environment').with_path('production') }
  end
end
