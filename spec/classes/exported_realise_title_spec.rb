require 'spec_helper'

describe 'exported::realise_title' do
  let(:exported_resources) do
    [
      'file' => {
        'foo' => {
          :owner => 'root',
          :group => 'root',
        },
        'foobar' => {
          :owner => 'daemon',
          :group => 'daemon',
        }
      }
    ]
  end

  it { should contain_file('foo').with_owner('root').with_group('root') }
  it { should_not contain_file('foobar') }
end
