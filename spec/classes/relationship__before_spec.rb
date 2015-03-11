require 'spec_helper'

describe 'relationships::before' do
  it { should contain_notify('foo').that_comes_before('Notify[bar]') }
  it { should contain_notify('foo').that_comes_before('Notify[baz]') }
  it { should contain_notify('bar').that_comes_before('Notify[baz]') }

  it { should contain_notify('bar').that_requires('Notify[foo]') }
  it { should contain_notify('baz').that_requires('Notify[foo]') }
  it { should contain_notify('baz').that_requires('Notify[bar]') }

  it { should contain_notify('foo').that_comes_before(['Notify[bar]','Notify[baz]']) }
  it { should contain_notify('bar').that_comes_before(['Notify[baz]']) }

  it { should contain_notify('bar').that_requires(['Notify[foo]']) }
  it { should contain_notify('baz').that_requires(['Notify[foo]','Notify[bar]']) }

  it { should contain_notify('pre').that_comes_before(['Notify[post]']) }
  it { should contain_notify('post').that_requires(['Notify[pre]']) }
end
