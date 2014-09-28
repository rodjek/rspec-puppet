require 'spec_helper'

describe 'test::classes_used' do
  it {
    expect(RSpec).to receive(:deprecate).with(:include_class, :contain_class)
    is_expected.to include_class('test::bare_class')
  }
  it {
    expect(RSpec).to receive(:deprecate).with(:include_class, :contain_class)
    is_expected.to include_class('test::parameterised_class')
  }

  it { is_expected.to contain_class('test::parameterised_class').with_text('bar') }
  it { is_expected.to contain_class('test::bare_class') }
end
