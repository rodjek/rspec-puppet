# frozen_string_literal: true

require 'spec_helper'

describe 'Aliases::Shape', if: Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  it { is_expected.to allow_value('square') }
  it { is_expected.to allow_value('circle') }
  it { is_expected.not_to allow_value('triangle') }
  it { is_expected.not_to allow_value(nil) }

  it { is_expected.to allow_values('square', 'circle') }
  it { is_expected.not_to allow_values('triangle', nil) }
end
