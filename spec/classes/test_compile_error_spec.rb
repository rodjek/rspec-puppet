require 'spec_helper'

describe 'test::compile_error' do
  it 'should provide a useful message when compilation fails' do
    is_expected.to compile.with_all_deps.and_raise_error(/Parameter managehome failed/)
  end
end
