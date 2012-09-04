require 'spec_helper'

describe 'virtual::realise_file' do
  let(:virtual_resources) {
    {
      :type => 'file',
      :title => 'foo',
      :parameters => {
        :owner => 'root',
        :group => 'root',
      }
    }
  }

  it { should contain_file('foo').with_owner('root').with_group('root') }
end
