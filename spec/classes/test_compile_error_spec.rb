# frozen_string_literal: true

require 'spec_helper'

describe 'test::compile_error' do
  it 'provides a useful message when compilation fails' do
    expect(subject).to compile.with_all_deps.and_raise_error(/Parameter managehome failed/)
  end
end
