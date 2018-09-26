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

  context 'using the new syntax', :if => RSpec::Core::Version::STRING.start_with?('3') do
    describe puppet_resource('notify', 'foo') do
      it { is_expected.to notify('Notify[bar]') }
    end

    describe puppet_resource('notify', 'baz') do
      it { is_expected.to notify('Notify[bar]') }
      it { is_expected.to notify('Notify[gronk]') }
      it { is_expected.to notify(['Notify[bar]', 'Notify[gronk]']) }
      it { is_expected.to notify('Notify[bar]', 'Notify[gronk]') }
    end

    describe puppet_resource('notify', 'gronk') do
      it { is_expected.to subscribe_to('Notify[baz]') }
    end

    describe puppet_resource('notify', 'bar') do
      it { is_expected.to subscribe_to('Notify[baz]', 'Notify[foo]') }
      it { is_expected.to subscribe_to(['Notify[baz]', 'Notify[foo]']) }
    end

    describe puppet_resource('notify', 'pre') do
      it { is_expected.to notify('Notify[post]') }
      it { is_expected.to notify(puppet_resource('notify', 'post')) }
    end

    describe puppet_resource('notify', 'post') do
      it { is_expected.to subscribe_to('Notify[pre]') }
    end
  end
end
