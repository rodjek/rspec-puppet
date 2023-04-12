# frozen_string_literal: true

require 'spec_helper'

describe 'test::provider_suitability' do
  [
    {
      operatingsystem: 'Darwin',
      osfamily: 'Darwin',
      kernel: 'Darwin'
    },
    {
      operatingsystem: 'CentOS',
      osfamily: 'RedHat',
      kernel: 'Linux'
    },
    {
      operatingsystem: 'Solaris',
      osfamily: 'Solaris',
      kernel: 'SunOS'
    }
  ].each do |f|
    context "On #{f[:operatingsystem]}" do
      let(:facts) { f }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_user('testuser') }
    end
  end
end
