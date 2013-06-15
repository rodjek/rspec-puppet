require 'spec_helper'

describe 'structured_data' do
  describe "with a single level array of strings" do
    let(:params) do
      {'data'  => ['foo', 'bar', 'baz', 'quux']}
    end

    it {
      should contain_structured_data__def('thing').with(
        { 'data'  => ['foo', 'bar', 'baz', 'quux'] }
      )
    }
  end

  describe "with integers as data values" do
    let(:params) do
      { 'data'  => ['first', 1, 'second', 2] }
    end

    it {
      should contain_structured_data__def('thing').with(
        { 'data' => ['first', 1, 'second', 2] }
      )
    }
  end

  describe 'with nested arrays' do
    let(:params) do
      { 'data'  => [
          'first',
          'second',
          ['third', 'fourth'],
          5,
          6
        ]
      }
    end

    # Puppet 2.6 will automatically flatten nested arrays. If we're going
    # to be testing recursive data structures, we might as well ensure that
    # we're still handling numeric values correctly.
    describe 'on Puppet 2.6', :if => Puppet.version =~ /^2\.6/ do
      it {
        should contain_structured_data__def('thing').with(
          { 'data'  => [
              'first',
              'second',
              'third',
              'fourth',
              5,
              6
            ]
          }
        )
      }
    end

    describe 'on Puppet 2.7 and later', :unless => Puppet.version =~ /^2\.6/ do
      it {
        should contain_structured_data__def('thing').with(
          { 'data'  => [
              'first',
              'second',
              ['third', 'fourth'],
              5,
              6
            ]
          }
        )
      }
    end
  end
end
