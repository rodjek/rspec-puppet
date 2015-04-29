require 'spec_helper'

describe 'undef_test' do
  it { should compile.with_all_deps }

  shared_examples 'exec echo' do
    it { should contain_exec('/bin/echo foo').with_user(nil) }
  end

  context 'with user => undef' do
    let(:params) { { :user => :undef } }
    include_examples 'exec echo'
  end

  context 'with params unset' do
    include_examples 'exec echo'
  end
end
