require 'spec_helper'

describe 'exported::realise_all' do
  let(:exported_resources) do
    {
      'file' => {
        '/foo' => {
          :owner => 'root',
          :group => 'root',
        },
        '/bar' => {
          :owner => 'daemon',
          :group => 'daemon',
        }
      }
    }
  end

  it { should contain_file('/foo').with_owner('root').with_group('root') }
  it { should contain_file('/bar').with_owner('daemon').with_group('daemon') }
end
