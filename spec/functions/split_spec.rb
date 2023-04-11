# frozen_string_literal: true

require 'spec_helper'

describe 'split' do
  it { is_expected.to run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  it { is_expected.not_to run.with_params('foo').and_raise_error(Puppet::DevError) }

  expected_error = if Puppet::Util::Package.versioncmp(Puppet.version, '3.1.0') >= 0
                     ArgumentError
                   else
                     Puppet::ParseError
                   end

  expected_error_message = if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
                             /expects \d+ arguments/
                           elsif Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
                             /mis-matched arguments/
                           else
                             /number of arguments/
                           end

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error) }

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error, expected_error_message) }

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error_message) }

  it {
    expect do
      expect(subject).to run.with_params('foo').and_raise_error(/definitely no match/)
    end.to raise_error RSpec::Expectations::ExpectationNotMetError
  }

  context 'after including a class' do
    let(:pre_condition) { 'include ::sysctl::common' }

    it { is_expected.to run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  end
end
