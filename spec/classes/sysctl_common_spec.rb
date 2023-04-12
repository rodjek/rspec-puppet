# frozen_string_literal: true

require 'spec_helper'

describe 'sysctl::common' do
  it {
    expect(subject).to contain_exec('sysctl/reload')
      .with_command('/sbin/sysctl -p /etc/sysctl.conf').with_returns([0, 2])
  }

  it { is_expected.not_to create_augeas('foo') }

  describe 'when using with to specify a hash of parameters' do
    it 'fails if the parameter is not contained in the resource' do
      expect do
        expect(subject).to contain_exec('sysctl/reload').with('foo' => 'bar')
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it 'passes if the parameters are contained in the resource' do
      expect(subject).to contain_exec('sysctl/reload').with(
        'refreshonly' => 'true',
        'returns' => [0, 2]
      )
    end
  end

  describe 'when using without to specify parameter name(s)' do
    it 'passes if the parameter name is not contained in the resource' do
      expect(subject).to contain_exec('sysctl/reload').without('foo')
    end

    it 'passes if the parameter names are not contained in the resource' do
      expect(subject).to contain_exec('sysctl/reload').without(%w[foo bar])
    end

    it 'fails if any of the parameter names are contained in the resource' do
      expect do
        expect(subject).to contain_exec('sysctl/reload').without(%w[foo returns])
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe 'when using without to specify parameter value(s)' do
    it 'passes if the parameter value is not contained in the resource' do
      expect(subject).to contain_exec('sysctl/reload').without_refreshonly('false')
    end

    it 'fails if the parameter value is contained in the resource' do
      expect do
        expect(subject).to contain_exec('sysctl/reload').without_refreshonly('true')
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end

describe 'sysctl::common' do
  let(:params) { { test_param: 'yes' } }

  it {
    expect(subject).to create_class('sysctl::common')
      .with_test_param('yes')
  }

  it { is_expected.to have_class_count(1) }
  it { is_expected.to have_exec_resource_count(1) }
  it { is_expected.to have_resource_count(2) }
  it { is_expected.to contain_notify('test') }
end

describe 'sysctl::common' do
  it {
    expect(subject).to contain_exec('sysctl/reload').only_with(
      command: '/sbin/sysctl -p /etc/sysctl.conf',
      refreshonly: true,
      returns: [0, 2]
    )
  }

  it {
    expect(subject).to contain_exec('sysctl/reload')
      .only_with_command('/sbin/sysctl -p /etc/sysctl.conf')
      .only_with_refreshonly(true)
      .only_with_returns([0, 2])
  }

  it 'fails if not enough parameters are contained in the resource' do
    expect do
      expect(subject).to contain_exec('sysctl/reload').only_with(
        command: '/sbin/sysctl -p /etc/sysctl.conf',
        returns: [0, 2]
      )
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'fails if different parameters are contained in the resource' do
    expect do
      expect(subject).to contain_exec('sysctl/reload').only_with(
        command: '/sbin/sysctl -p /etc/sysctl.conf',
        refreshonly: true,
        creates: '/tmp/bla'
      )
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
