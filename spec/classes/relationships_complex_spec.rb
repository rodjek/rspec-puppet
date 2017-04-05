require 'spec_helper'

describe 'relationships::complex' do
  it { should contain_notify('foo').that_comes_before(['Notify[baz]', 'Notify[bar]']) }
end
