require 'spec_helper'

describe 'virtual::realise_file' do
  it { should contain_file('/foo').with_owner('root').with_group('root') }
  it { should_not contain_file('/bar') }
end
