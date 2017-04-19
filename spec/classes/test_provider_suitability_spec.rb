require 'spec_helper'

describe 'test::provider_suitability' do
  [
    {
      :operatingsystem => 'Darwin',
      :osfamily => 'Darwin',
      :kernel => 'Darwin',
    },
    {
      :operatingsystem => 'CentOS',
      :osfamily => 'RedHat',
      :kernel => 'Linux',
    },
    {
      :operatingsystem => 'Solaris',
      :osfamily => 'Solaris',
      :kernel => 'SunOS',
    },
  ].each do |f|
    context "On #{f[:operatingsystem]}" do
      let(:facts) { f }

      it { should compile.with_all_deps }
      it { should contain_user('testuser') }
    end
  end
end
