require 'spec_helper'

describe 'split' do
  it { is_expected.to run.with_params('aoeu', 'o').and_return(['a', 'eu']) }
  it { is_expected.not_to run.with_params('foo').and_raise_error(Puppet::DevError) }

  if (Puppet.version.split('.').map { |s| s.to_i } <=> [3, 1]) >= 0
    expected_error = ArgumentError
  else
    expected_error = Puppet::ParseError
  end

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error) }

  it { is_expected.to run.with_params('foo').and_raise_error(expected_error, /number of arguments/) }

  it { is_expected.to run.with_params('foo').and_raise_error(/number of arguments/) }

  it 'should fail with one argument - match exception type' do
    expect { subject.call(['foo']) }.to raise_error(expected_error)
  end

  it 'should fail with one argument - match exception type and message' do
    expect { subject.call(['foo']) }.to raise_error(expected_error, /number of arguments/)
  end

  it 'should fail with one argument - match exception message' do
    expect { subject.call(['foo']) }.to raise_error(/number of arguments/)
  end
end
