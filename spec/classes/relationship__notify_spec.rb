require 'spec_helper'

describe 'relationships::notify' do
  it { should contain_notify('foo').that_notifies('Notify[bar]') }
  it { should contain_notify('baz').that_notifies('Notify[bar]') }
  it { should contain_notify('baz').that_notifies('Notify[gronk]') }

  it { should contain_notify('gronk').that_subscribes_to('Notify[baz]') }
  it { should contain_notify('bar').that_subscribes_to('Notify[baz]') }
  it { should contain_notify('bar').that_subscribes_to('Notify[foo]') }

  it { should contain_notify('foo').that_notifies(['Notify[bar]']) }
  it { should contain_notify('baz').that_notifies(['Notify[bar]','Notify[gronk]']) }

  it { should contain_notify('gronk').that_subscribes_to(['Notify[baz]']) }
  it { should contain_notify('bar').that_subscribes_to(['Notify[baz]','Notify[foo]']) }

  it { should contain_notify('pre').that_notifies(['Notify[post]']) }
  it { should contain_notify('post').that_subscribes_to(['Notify[pre]']) }
end
