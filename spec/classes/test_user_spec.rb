require 'spec_helper'

describe 'test::user' do
  it { should contain_user('luke').only_with({
    'ensure' => 'present',
    'uid'    => '501',
  }) }
end
