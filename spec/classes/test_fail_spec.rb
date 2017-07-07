require 'spec_helper'

describe 'test::fail' do
  it { should compile.and_raise_error(%r{test}) }
end
