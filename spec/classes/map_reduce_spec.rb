# frozen_string_literal: true

require 'spec_helper'

describe 'map_reduce', if: (Puppet.version.to_f >= 4.0 || RSpec.configuration.parser == 'future') do
  let(:params) do
    {
      values: [0, 1, 2]
    }
  end

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to create_notify('joined_incremented_values').with_message('123') }
end
