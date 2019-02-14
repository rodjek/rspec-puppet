require 'spec_helper'

describe 'deferred', :if => Puppet::Util::Package.versioncmp(Puppet.version, '6.0.0') >= 0 do
  it { should contain_notify('deferred msg').with_message('A STRING') }
end
