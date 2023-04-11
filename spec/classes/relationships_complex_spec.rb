# frozen_string_literal: true

require 'spec_helper'

describe 'relationships::complex' do
  it { is_expected.to contain_notify('foo').that_comes_before(['Notify[baz]', 'Notify[bar]']) }
end
