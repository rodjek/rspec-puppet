require 'spec_helper'

describe 'test::loop_define' do
  context 'with an array of plain strings' do
    let(:title) { ['a', 'b'] }

    context 'both sub resources in the catalogue' do
      it { should contain_package('a') }
      it { should contain_package('b') }
    end
  end

  context 'with a title containing a $' do
    let(:title) { '$test' }

    it { should compile }
  end
end
