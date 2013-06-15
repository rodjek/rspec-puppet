require 'spec_helper'

describe 'structured_data' do
  describe "with a single level hash of strings" do
    let(:params) do
      {'data'  => {'foo' => 'bar', 'baz' => 'quux'}}
    end

    it {
      should contain_structured_data__def('thing').with(
        {'data'  => {'foo' => 'bar', 'baz' => 'quux'}}
      )
    }
  end

  describe "with integers as keys" do
    let(:params) do
      { 'data'  => {1 => 'uno', 2 => 'dos'}}
    end

    it {
      should contain_structured_data__def('thing').with(
        { 'data'  => {1 => 'uno', 2 => 'dos'}}
      )
    }
  end

  describe 'with integers as values' do
    let(:params) do
      { 'data'  => {'first' => 1, 'second' => 2}}
    end

    it {
      should contain_structured_data__def('thing').with(
        { 'data'  => {'first' => 1, 'second' => 2}}
      )
    }
  end

  describe 'with nested hashes' do
    let(:params) do
      { 'data'  => {
          'first'  => 1,
          'second' => 2,
          'third'  => {
            'alpha' => 'a',
            'beta'  => 'b',
          }
        }
      }
    end

    it {
      should contain_structured_data__def('thing').with(
        { 'data'  => {
            'first'  => 1,
            'second' => 2,
            'third'  => {
              'alpha' => 'a',
              'beta'  => 'b',
            }
          }
        }
      )
    }
  end
end

