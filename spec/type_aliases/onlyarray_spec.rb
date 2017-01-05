require 'spec_helper'

describe 'Aliases::OnlyArray', :if => Puppet.version.to_f >= 4.4 do
  it { is_expected.not_to allow_value(nil, 'string') }
  it { is_expected.to allow_value(['a', 'b']) }
end
