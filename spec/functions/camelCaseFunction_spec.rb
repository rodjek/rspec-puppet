require 'spec_helper'

describe 'camelCaseFunction' do
  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /Requires 1 argument/) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, /Argument must be a string/) }
  it { is_expected.to run.with_params('test').and_return('test') }
end
