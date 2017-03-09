require 'spec_helper'

describe 'test::addition' do
  let(:title) { 'testtitle' }

  context 'when passing an integer' do
    let(:params) { {:value => 60} }

    it { should contain_notify('61') }
  end
end
