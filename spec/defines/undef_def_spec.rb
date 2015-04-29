require 'spec_helper'

describe 'undef::def' do
  let(:title) { '/bin/echo foo' }

  it { should compile.with_all_deps }

  shared_examples 'exec echo' do
    it { should contain_exec('/bin/echo foo').with_user(nil) }
  end

  context 'with user => nil' do
    let(:params) { { :user => nil } }
    include_examples 'exec echo'
  end

  context 'with params unset' do
    include_examples 'exec echo'
  end
end
