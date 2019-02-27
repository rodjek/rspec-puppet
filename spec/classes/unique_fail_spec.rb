# frozen_string_literal: true

require 'spec_helper'

describe 'unique::fail' do
  it { should compile }
  it { should_not have_unique_values_for_all('user', 'uid') }
end
