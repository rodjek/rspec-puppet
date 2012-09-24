require 'spec_helper'

describe 'exported::export_files' do
  it {
    #should export_file('/foo').with_owner('root').with_group('root')
    should contain_file('/foo').with_owner('root').with_group('root')
  }
  it {
    #should export_file('/foobar').with_owner('daemon').with_group('daemon')
    should contain_file('/foobar').with_owner('daemon').with_group('daemon')
  }
  it {
    #should export_file('/quux').with_owner('toor').with_group('toor')
    should_not contain_file('/quux').with_owner('toor').with_group('toor')
  }
  it {
    #should_not export_package('baz')
    should contain_package('baz')
  }
  it {
    #should_not export_package('zot')
    should_not contain_package('zot')
  }
end
