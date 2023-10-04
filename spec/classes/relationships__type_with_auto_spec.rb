# frozen_string_literal: true

require 'spec_helper'

describe 'relationships::type_with_auto' do
  it { is_expected.to compile.with_all_deps }

  it do
    expect(subject).to contain_type_with_all_auto('test')
      .that_comes_before('Notify[test/before]')
      .that_notifies('Notify[test/notify]')
      .that_requires('Notify[test/require]')
      .that_subscribes_to('Notify[test/subscribe]')
  end

  it { is_expected.to contain_notify('test/before').that_requires('Type_with_all_auto[test]') }
  it { is_expected.to contain_notify('test/notify').that_subscribes_to('Type_with_all_auto[test]') }
  it { is_expected.to contain_notify('test/require').that_comes_before('Type_with_all_auto[test]') }
  it { is_expected.to contain_notify('test/subscribe').that_notifies('Type_with_all_auto[test]') }
end
