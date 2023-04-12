# frozen_string_literal: true

require 'spec_helper'

describe 'default_test', if: Puppet.version.to_f >= 4.0 do
  let(:params) { { value: :default } }

  it { is_expected.to compile.with_all_deps }
end
