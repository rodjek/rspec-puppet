require 'spec_helper'

describe 'hash' do
  let(:title) { 'huh?' }
  let(:params) do
    {
      'data'  => {
        'baz' => 'quux',
        'foo' => 'bar',
      }
    }
  end

  it {
    should contain_hash__def('thing').with({
      'data'  => {
        'foo' => 'bar',
        'baz' => 'quux',
      }
    })
  }

  it {
    should contain_hash__def('thing').with({
      'data'  => {
        'baz' => 'quux',
        'foo' => 'bar',
      }
    })
  }
end
