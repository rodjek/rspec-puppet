require 'spec_helper'

describe 'exported::realise_file' do
  let(:exported_resources) { [
    {
      :type => 'file',
      :title => 'foo',
      :parameters => {
        :owner => 'root',
        :group => 'root',
      }
    },
    {
      :type => 'file',
      :title => 'baz',
      :parameters => {
        :owner => 'bob',
        :group => 'bob',
      }
    },
    {
      :type => 'file',
      :title => 'foobar',
      :parameters => {
        :owner => 'daemon',
        :group => 'daemon',
      }
    }
  ] }

  it { should contain_file('foo').with_owner('root').with_group('root') }
  it { should contain_file('baz').with_owner('bob').with_group('bob') }
  it { should_not contain_file('foobar') }
end
