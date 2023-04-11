# frozen_string_literal: true

require 'spec_helper'

describe 'test::loop_define' do
  context 'with an array of plain strings' do
    let(:title) { %w[a b] }

    context 'both sub resources in the catalogue' do
      it { is_expected.to contain_package('a') }
      it { is_expected.to contain_package('b') }
    end
  end

  context 'with a title containing a $' do
    let(:title) { '$test' }

    it { is_expected.to compile }
  end
end
