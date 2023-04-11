# frozen_string_literal: true

require 'spec_helper'

describe 'cycle::bad' do
  it { is_expected.not_to compile }
end
