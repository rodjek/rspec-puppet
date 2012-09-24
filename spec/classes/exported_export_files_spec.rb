require 'spec_helper'

describe 'exported::export_files' do
  it {
    should contain_file('/foo').with_owner('root').with_group('root')
  }
  it {
    should contain_file('/foobar').with_owner('daemon').with_group('daemon')
  }
  it {
    should_not contain_file('/quux').with_owner('toor').with_group('toor')
  }
  it {
    should contain_package('baz')
  }
  it {
    should_not contain_package('zot')
  }
end
