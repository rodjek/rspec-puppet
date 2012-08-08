require 'spec_helper'

describe 'split' do
  it { should run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  it { should run.with_params('foo').and_raise_error(Puppet::ParseError) }
  it { should_not run.with_params('foo').and_raise_error(Puppet::DevError) }

  it 'something' do
    expect { subject.call('foo') }.to raise_error(Puppet::ParseError)
  end
end
