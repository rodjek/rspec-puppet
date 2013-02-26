require 'spec_helper'

describe 'split' do
  it { should run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  it { should_not run.with_params('foo').and_raise_error(Puppet::DevError) }

  if Puppet.version =~ /\A3\.1/
    expected_error = ArgumentError
  else
    expected_error = Puppet::ParseError
  end

  it { should run.with_params('foo').and_raise_error(expected_error) }

  it 'should fail with one argument' do
    expect { subject.call(['foo']) }.to raise_error(expected_error)
  end
end
