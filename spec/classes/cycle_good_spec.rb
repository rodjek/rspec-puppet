require 'spec_helper'

describe 'cycle::good' do
  it { should compile }
  it { should_not compile.and_raise_error(//) }
end
