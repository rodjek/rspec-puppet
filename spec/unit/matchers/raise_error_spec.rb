# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/support'

describe RSpec::Puppet::GenericMatchers::RaiseError do
  include RSpec::Puppet::GenericMatchers

  context 'with a failing target' do
    subject { -> { raise 'catalogue load failed' } }

    it { is_expected.to raise_error 'catalogue load failed' }
  end

  context 'with a passing target' do
    subject { -> {} }

    it { is_expected.not_to raise_error }
  end
end
