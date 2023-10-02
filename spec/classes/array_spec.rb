# frozen_string_literal: true

require 'spec_helper'

describe 'structured_data' do
  describe 'with a single level array of strings' do
    let(:params) do
      { 'data' => %w[foo bar baz quux] }
    end

    it {
      expect(subject).to contain_structured_data__def('thing').with(
        { 'data' => %w[foo bar baz quux] }
      )
    }
  end

  describe 'with integers as data values' do
    let(:params) do
      { 'data' => ['first', 1, 'second', 2] }
    end

    it {
      expect(subject).to contain_structured_data__def('thing').with(
        { 'data' => ['first', 1, 'second', 2] }
      )
    }
  end

  describe 'with nested arrays' do
    let(:params) do
      { 'data' => [
        'first',
        'second',
        %w[third fourth],
        5,
        6
      ] }
    end

    it {
      expect(subject).to contain_structured_data__def('thing').with(
        { 'data' => [
          'first',
          'second',
          %w[third fourth],
          5,
          6
        ] }
      )
    }
  end
end
