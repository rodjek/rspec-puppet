require 'spec_helper'

describe 'split' do
  it { should run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  it { should run.with_params('foo').and_raise_error(Puppet::ParseError) }
  it { should_not run.with_params('foo').and_raise_error(Puppet::DevError) }

  it 'something' do
    if Integer(Puppet.version.split('.').first) >= 3
      expected_error = ArgumentError
    else
      expected_error = Puppet::ParseError
    end

    expect { subject.call('foo') }.to raise_error(expected_error)
  end
end
