# frozen_string_literal: true

require 'spec_helper'

describe 'Aliases::Shape' do
  it { is_expected.to allow_value('square') }
  it { is_expected.to allow_value('circle') }
  it { is_expected.not_to allow_value('triangle') }
  it { is_expected.not_to allow_value(nil) }

  it { is_expected.to allow_values('square', 'circle') }
  it { is_expected.not_to allow_values('triangle', nil) }
end
