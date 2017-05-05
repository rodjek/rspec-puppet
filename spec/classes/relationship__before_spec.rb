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

  it { should contain_class('relationship::before::pre').that_comes_before('Class[relationship::before::post]') }
  it { should contain_class('relationship::before::post').that_requires('Class[relationship::before::pre]') }

  it { should contain_notify('pre').that_comes_before(['Notify[post]']) }
  it { should contain_notify('post').that_requires(['Notify[pre]']) }

  it { should contain_file('/tmp/foo').that_comes_before(['File[/tmp/foo/bar]']) }
  it { should contain_file('/tmp/foo/bar').that_requires(['File[/tmp/foo]']) }

  it { should contain_notify('bazz').that_comes_before(['File[/tmp/foo/bar]']) }
  it { should contain_notify('qux').that_requires(['File[/tmp/foo]']) }
  it { should contain_notify('bazz').that_comes_before(['Notify[qux]']) }
  it { should contain_notify('qux').that_requires(['Notify[bazz]']) }

  it { should_not contain_notify('foo').that_comes_before('Notify[unknown]') }
  it { should_not contain_notify('bar').that_comes_before('Notify[unknown]') }
  it { should_not contain_notify('baz').that_comes_before('Notify[unknown]') }

  it { should_not contain_notify('foo').that_requires('Notify[unknown]') }
  it { should_not contain_notify('bar').that_requires('Notify[unknown]') }
  it { should_not contain_notify('baz').that_requires('Notify[unknown]') }

  it { should_not contain_class('relationship::before::pre').that_comes_before('Class[relationship::before::unknown]') }
  it { should_not contain_class('relationship::before::post').that_requires('Class[relationship::before::unknown]') }
end
