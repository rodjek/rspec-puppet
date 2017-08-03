require 'spec_helper'

describe 'test::duplicate_alias' do
  let(:facts) { { 'operatingsystem' => 'Debian' } }
  it { should compile }
  it { should contain_exec('foo_bar_1') }
  it { should contain_exec('foo_bar_2') }
  it { should_not contain_exec('/bin/echo foo bar') }
end
