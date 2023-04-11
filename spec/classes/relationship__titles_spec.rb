# frozen_string_literal: true

require 'spec_helper'

describe 'relationships::titles' do
  let(:facts) { { operatingsystem: 'Debian', osfamily: 'debian', kernel: 'Linux' } }

  it { is_expected.to compile }
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_file('/etc/svc') }
  it { is_expected.to contain_service('svc-title') }

  it { is_expected.to contain_file('/etc/svc').that_notifies('Service[svc-name]') }
  it { is_expected.to contain_file('/etc/svc').that_comes_before('Service[svc-name]') }
  it { is_expected.to contain_service('svc-title').that_requires('File[/etc/svc]') }
  it { is_expected.to contain_service('svc-title').that_subscribes_to('File[/etc/svc]') }
end
