require 'spec_helper'

describe 'relationships::before' do
  it { is_expected.to contain_notify('foo').that_comes_before('Notify[bar]') }
  it { is_expected.to contain_notify('foo').that_comes_before('Notify[baz]') }
  it { is_expected.to contain_notify('bar').that_comes_before('Notify[baz]') }

  it { is_expected.to contain_notify('bar').that_requires('Notify[foo]') }
  it { is_expected.to contain_notify('baz').that_requires('Notify[foo]') }
  it { is_expected.to contain_notify('baz').that_requires('Notify[bar]') }

  it { is_expected.to contain_notify('foo').that_comes_before(['Notify[bar]','Notify[baz]']) }
  it { is_expected.to contain_notify('bar').that_comes_before(['Notify[baz]']) }

  it { is_expected.to contain_notify('bar').that_requires(['Notify[foo]']) }
  it { is_expected.to contain_notify('baz').that_requires(['Notify[foo]','Notify[bar]']) }
end
