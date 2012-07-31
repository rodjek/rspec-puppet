require 'spec_helper'

describe 'sysctl::common' do
  it { should contain_exec('sysctl/reload') \
    .with_command('/sbin/sysctl -p /etc/sysctl.conf').with_returns([0, 2]) }
  it { should_not create_augeas('foo') }
  describe 'when using with to specify a hash of parameters' do
    it 'should fail if the parameter is not contained in the resource' do
      expect do
        subject.should contain_exec('sysctl/reload').with('foo' => 'bar')
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
    it 'should pass if the parameters are contained in the resource' do
      subject.should contain_exec('sysctl/reload').with(
        'refreshonly' => 'true',
        'returns' => [0, 2]
      )
    end
  end
  describe 'when using without to specify parameter name(s)' do
    it 'should pass if the parameter name is not contained in the resource' do
      subject.should contain_exec('sysctl/reload').without('foo')
    end
    it 'should pass if the parameter names are not contained in the resource' do
      subject.should contain_exec('sysctl/reload').without(['foo', 'bar'])
    end
    it 'should fail if any of the parameter names are contained in the resource' do
      expect do
        subject.should contain_exec('sysctl/reload').without(['foo', 'returns'])
      end.should raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end

describe 'sysctl::common' do
  let(:params) { { :test_param => "yes" } }

  it { should create_class("sysctl::common")\
    .with_test_param("yes") }
end
