require 'spec_helper'

describe 'nil_function' do
  it { should run.with_params(false).and_return(nil) }
  it { should run.with_params(true).and_raise_error(Puppet::ParseError, %r{Forced Failure}) }

  let(:version) do
    if Puppet[:parser] == 'future' || Puppet.version.to_f >= 4
      'new version'
    else
      'old version'
    end
  end
  it { should run.with_params(true).and_raise_error(Puppet::ParseError, %r{Forced Failure - #{version}}) }
end
