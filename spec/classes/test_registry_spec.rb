# frozen_string_literal: true

require 'spec_helper'

describe 'test::registry', if: Puppet.version.to_f >= 4.0 do
  let(:facts) { { os: { name: 'windows' } } }

  it { is_expected.to compile.with_all_deps }
end
