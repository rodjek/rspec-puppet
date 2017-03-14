require 'spec_helper'

describe 'test::classes_used' do
  it {
    expect(RSpec).to receive(:deprecate).with(:include_class, {:replacement => :contain_class})
    should include_class('test::bare_class')
  }
  it {
    expect(RSpec).to receive(:deprecate).with(:include_class, {:replacement => :contain_class})
    should include_class('test::parameterised_class')
  }

  it { should contain_class('test::parameterised_class').with_text('bar') }
  it { should contain_class('test::bare_class') }
  it { should contain_class('test::parameterised_class').with_something(Proc.new { |v| v.nil? || v.empty? }) }
end
