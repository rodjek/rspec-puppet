# frozen_string_literal: true

require 'spec_helper'

describe 'Aliases::OnlyArray' do
  it { is_expected.not_to allow_value(nil, 'string') }
  it { is_expected.to allow_value(%w[a b]) }
end
