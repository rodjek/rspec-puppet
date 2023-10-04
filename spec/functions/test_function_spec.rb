# frozen_string_literal: true

require 'spec_helper'

describe 'test_function' do
  # Verify that we can load functions from modules
  it { is_expected.to run.with_params('foo').and_return(/value is foo/) }
end

describe 'frozen_function' do
  it { is_expected.to run.with_params('foo').and_return(true) }
  it { is_expected.to run.with_params(String).and_return(false) }
  it { is_expected.to run.with_params(true).and_return(true) }
  it { is_expected.to run.with_params(['foo']).and_return(true) }
  it { is_expected.to run.with_params('foo' => 'bar').and_return(true) }
end
