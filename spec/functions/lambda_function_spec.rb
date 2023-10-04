# frozen_string_literal: true

require 'spec_helper'

describe 'map' do
  it { is_expected.to run.with_params([1, 2]).with_lambda { |x| "test-#{x}" }.and_return(%w[test-1 test-2]) }
end
