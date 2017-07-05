require 'spec_helper'

describe 'test::user' do
  it do
    should contain_user('luke').only_with(
      'ensure' => 'present',
      'uid'    => '501'
    )
  end
end
