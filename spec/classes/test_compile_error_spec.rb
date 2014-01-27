require 'spec_helper'

describe 'test::compile_error' do
  it 'should provide a useful message when compilation fails' do
    should compile.with_all_deps.and_raise_error(/Parameter managehome failed/)
  end
end
