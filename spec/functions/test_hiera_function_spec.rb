# frozen_string_literal: true

require 'spec_helper'

describe 'test::hiera_function' do
  context 'with :hiera_config set' do
    let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

    it { is_expected.to run.and_return('foo') }
  end

  context 'without :hiera_config set' do
    it { is_expected.to run.and_return('not found') }
  end
end
