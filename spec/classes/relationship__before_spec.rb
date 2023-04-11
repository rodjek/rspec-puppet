# frozen_string_literal: true

require 'spec_helper'

describe 'relationships::before' do
  let(:facts) { { operatingsystem: 'debian' } }

  it { is_expected.to contain_notify('foo').that_comes_before('Notify[bar]') }
  it { is_expected.to contain_notify('foo').that_comes_before('Notify[baz]') }
  it { is_expected.to contain_notify('bar').that_comes_before('Notify[baz]') }

  it { is_expected.to contain_notify('bar').that_requires('Notify[foo]') }
  it { is_expected.to contain_notify('baz').that_requires('Notify[foo]') }
  it { is_expected.to contain_notify('baz').that_requires('Notify[bar]') }

  it { is_expected.to contain_notify('foo').that_comes_before(['Notify[bar]', 'Notify[baz]']) }
  it { is_expected.to contain_notify('bar').that_comes_before(['Notify[baz]']) }

  it { is_expected.to contain_notify('bar').that_requires(['Notify[foo]']) }
  it { is_expected.to contain_notify('baz').that_requires(['Notify[foo]', 'Notify[bar]']) }

  it {
    expect(subject).to contain_class('relationships::before::pre').that_comes_before('Class[relationships::before::post]')
  }

  it { is_expected.to contain_class('relationships::before::post').that_requires('Class[relationships::before::pre]') }

  it { is_expected.to contain_notify('pre').that_comes_before(['Notify[post]']) }
  it { is_expected.to contain_notify('post').that_requires(['Notify[pre]']) }

  it { is_expected.to contain_file('/tmp/foo').that_comes_before(['File[/tmp/foo/bar]']) }
  it { is_expected.to contain_file('/tmp/foo/bar').that_requires(['File[/tmp/foo]']) }

  it { is_expected.to contain_notify('bazz').that_comes_before(['File[/tmp/foo/bar]']) }
  it { is_expected.to contain_notify('qux').that_requires(['File[/tmp/foo]']) }
  it { is_expected.to contain_notify('bazz').that_comes_before(['Notify[qux]']) }
  it { is_expected.to contain_notify('qux').that_requires(['Notify[bazz]']) }

  it { is_expected.not_to contain_notify('foo').that_comes_before('Notify[unknown]') }
  it { is_expected.not_to contain_notify('bar').that_comes_before('Notify[unknown]') }
  it { is_expected.not_to contain_notify('baz').that_comes_before('Notify[unknown]') }

  it { is_expected.not_to contain_notify('foo').that_requires('Notify[unknown]') }
  it { is_expected.not_to contain_notify('bar').that_requires('Notify[unknown]') }
  it { is_expected.not_to contain_notify('baz').that_requires('Notify[unknown]') }

  it {
    expect(subject).not_to contain_class('relationships::before::pre').that_comes_before('Class[relationships::before::unknown]')
  }

  it {
    expect(subject).not_to contain_class('relationships::before::post').that_requires('Class[relationships::before::unknown]')
  }
end
