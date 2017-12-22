require 'spec_helper'

describe 'test::multi_os' do
  context 'on windows' do
    let(:facts) do
      { :operatingsystem => 'windows' }
    end

    it { should compile.with_all_deps }

    it 'sets the provider of the File resource to :windows' do
      catalogue.resource('file', 'C:/test').to_ral.provider.class.name.should eq(:windows)
    end
  end

  context 'on Debian' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
    end

    it { should compile.with_all_deps }

    it 'sets the provider of the File resource to :posix' do
      catalogue.resource('file', '/test').to_ral.provider.class.name.should eq(:posix)
    end
  end
end
