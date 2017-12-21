require 'spec_helper'

describe 'relationships::titles' do
  let(:facts) { {:operatingsystem => 'Debian', :osfamily => 'debian', :kernel => 'Linux'} }

  it { should compile }
  it { should compile.with_all_deps }

  it { should contain_file('/etc/svc') }
  it { should contain_service('svc-title') }

  it { should contain_file('/etc/svc').that_notifies('Service[svc-name]') }
  it { should contain_file('/etc/svc').that_comes_before('Service[svc-name]') }
  it { should contain_service('svc-title').that_requires('File[/etc/svc]') }
  it { should contain_service('svc-title').that_subscribes_to('File[/etc/svc]') }
end
