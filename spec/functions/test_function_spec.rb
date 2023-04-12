# frozen_string_literal: true

require 'spec_helper'

describe 'test_function', if: Puppet.version.to_f >= 4.0 do
  # Verify that we can load functions from modules
  it { is_expected.to run.with_params('foo').and_return(/value is foo/) }
end

describe 'frozen_function', if: Puppet.version.to_f >= 4.0 do
  it { is_expected.to run.with_params('foo').and_return(true) }
  it { is_expected.to run.with_params(String).and_return(false) }
  it { is_expected.to run.with_params(true).and_return(true) }
  it { is_expected.to run.with_params(['foo']).and_return(true) }
  it { is_expected.to run.with_params('foo' => 'bar').and_return(true) }
end
