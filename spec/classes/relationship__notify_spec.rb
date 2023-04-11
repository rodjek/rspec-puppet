# frozen_string_literal: true

require 'spec_helper'

describe 'relationships::notify' do
  it { is_expected.to contain_notify('foo').that_notifies('Notify[bar]') }
  it { is_expected.to contain_notify('baz').that_notifies('Notify[bar]') }
  it { is_expected.to contain_notify('baz').that_notifies('Notify[gronk]') }

  it { is_expected.to contain_notify('gronk').that_subscribes_to('Notify[baz]') }
  it { is_expected.to contain_notify('bar').that_subscribes_to('Notify[baz]') }
  it { is_expected.to contain_notify('bar').that_subscribes_to('Notify[foo]') }

  it { is_expected.to contain_notify('foo').that_notifies(['Notify[bar]']) }
  it { is_expected.to contain_notify('baz').that_notifies(['Notify[bar]', 'Notify[gronk]']) }

  it { is_expected.to contain_notify('gronk').that_subscribes_to(['Notify[baz]']) }
  it { is_expected.to contain_notify('bar').that_subscribes_to(['Notify[baz]', 'Notify[foo]']) }

  it { is_expected.to contain_notify('pre').that_notifies(['Notify[post]']) }
  it { is_expected.to contain_notify('post').that_subscribes_to(['Notify[pre]']) }
end
