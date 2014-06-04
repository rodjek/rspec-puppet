require 'spec_helper'

describe 'test::fail' do
  it { is_expected.to compile.and_raise_error(/test/) }
end
