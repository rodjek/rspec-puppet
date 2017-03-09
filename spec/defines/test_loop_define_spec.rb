require 'spec_helper'

describe 'test::loop_define' do
  let(:title) { ['a', 'b'] }

  context 'both sub resources in the catalogue' do
    it { should contain_package('a') }
    it { should contain_package('b') }
  end
end
