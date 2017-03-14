require 'spec_helper'

describe 'split' do
  it { should run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  it { should_not run.with_params('foo').and_raise_error(Puppet::DevError) }

  if Puppet::Util::Package.versioncmp(Puppet.version, '3.1.0') >= 0
    expected_error = ArgumentError
  else
    expected_error = Puppet::ParseError
  end

  if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
    expected_error_message = /expects \d+ arguments/
  elsif Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
    expected_error_message = /mis-matched arguments/
  else
    expected_error_message = /number of arguments/
  end

  it { should run.with_params('foo').and_raise_error(expected_error) }

  it { should run.with_params('foo').and_raise_error(expected_error, expected_error_message) }

  it { should run.with_params('foo').and_raise_error(expected_error_message) }

  it { expect { should run.with_params('foo').and_raise_error(/definitely no match/) }.to raise_error RSpec::Expectations::ExpectationNotMetError }

  context 'after including a class' do
    let(:pre_condition) { 'include ::sysctl::common' }
    it { should run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  end
end
