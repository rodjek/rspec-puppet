require 'spec_helper'

describe 'test::sensitive', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.6.0') >= 0 do
  it { is_expected.to contain_class('test::sensitive::user').with_password(sensitive('myPassword')) }
end
