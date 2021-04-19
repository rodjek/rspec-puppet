require 'spec_helper'

describe 'relationships::type_with_auto', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0 do
  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_type_with_all_auto('/tmp')
      .that_comes_before('File[/tmp/before]')
      .that_notifies('File[/tmp/notify]')
      .that_requires('File[/tmp/require]')
      .that_subscribes_to('File[/tmp/subscribe]')
  end

  it { is_expected.to contain_file('/tmp/before').that_requires('Type_with_all_auto[/tmp]') }
  it { is_expected.to contain_file('/tmp/notify').that_subscribes_to('Type_with_all_auto[/tmp]') }
  it { is_expected.to contain_file('/tmp/require').that_comes_before('Type_with_all_auto[/tmp]') }
  it { is_expected.to contain_file('/tmp/subscribe').that_notifies('Type_with_all_auto[/tmp]') }
end
