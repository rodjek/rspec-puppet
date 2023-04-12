# frozen_string_literal: true

require 'spec_helper'

describe 'cycle::good' do
  it { is_expected.to compile }
  it { is_expected.not_to compile.and_raise_error(//) }
end
