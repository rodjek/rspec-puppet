require 'spec_helper'

describe 'camelCaseFunction' do
  it { should_not be_nil }
  it { should run.with_params.and_raise_error(Puppet::ParseError, %r{Requires 1 argument}) }
  it { should run.with_params(1).and_raise_error(Puppet::ParseError, %r{Argument must be a string}) }
  it { should run.with_params('test').and_return('test') }
end
