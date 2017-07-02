require 'spec_helper'

describe 'Aliases::OnlyHash', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  it { is_expected.not_to allow_value(nil, 'string') }
  it { is_expected.to allow_value('a' => 'b') }
  it { is_expected.to allow_value('a' => {'b' => 'c'}) }
end
