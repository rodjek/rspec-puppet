require 'spec_helper'

describe 'Aliases::Shape', :if => Puppet.version.to_f >= 4.4 do
  it { is_expected.to allow_value('square') }
  it { is_expected.to allow_value('circle') }
  it { is_expected.not_to allow_value('triangle') }
  it { is_expected.not_to allow_value(nil) }

  it { is_expected.to allow_values('square', 'circle') }
  it { is_expected.not_to allow_values('triangle', nil) }
end
