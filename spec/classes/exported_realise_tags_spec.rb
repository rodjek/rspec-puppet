require 'spec_helper'

describe 'exported::realise_tags' do
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
      :title => 'foobar',
      :parameters => {
        :owner => 'daemon',
        :group => 'daemon',
      }
    },
    {
      :type => 'package',
      :title => 'baz',
      :parameters => {
        :ensure => 'present'
      }
    }
  ] }

  it { should contain_file('foo').with_owner('root').with_group('root') }
  it { should contain_file('foobar').with_owner('daemon').with_group('daemon') }
  it { should_not contain_package('baz') }
end
