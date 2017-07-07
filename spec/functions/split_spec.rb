require 'spec_helper'

describe 'split' do
  let(:expected_error) do
    if Puppet::Util::Package.versioncmp(Puppet.version, '3.1.0') >= 0
      ArgumentError
    else
      Puppet::ParseError
    end
  end

  let(:expected_error_message) do
    if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
      %r{expects \d+ arguments}
    elsif Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
      %r{mis-matched arguments}
    else
      %r{number of arguments}
    end
  end

  it { should run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  it { should_not run.with_params('foo').and_raise_error(Puppet::DevError) }

  it { should run.with_params('foo').and_raise_error(expected_error) }

  it { should run.with_params('foo').and_raise_error(expected_error, expected_error_message) }

  it { should run.with_params('foo').and_raise_error(expected_error_message) }

  it { expect { should run.with_params('foo').and_raise_error(%r{definitely no match}) }.to raise_error RSpec::Expectations::ExpectationNotMetError }

  context 'after including a class' do
    let(:pre_condition) { 'include ::sysctl::common' }
    it { should run.with_params('aoeu', 'o').and_return(%w[a eu]) }
  end
end
