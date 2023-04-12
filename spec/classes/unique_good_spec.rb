# frozen_string_literal: true

require 'spec_helper'

describe 'unique' do
  it { is_expected.to compile }
  it { is_expected.to have_unique_values_for_all('user', 'uid') }
end
