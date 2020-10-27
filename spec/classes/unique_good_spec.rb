# frozen_string_literal: true

require 'spec_helper'

describe 'unique' do
  it { should compile }
  it { should have_unique_values_for_all('user', 'uid') }
end
