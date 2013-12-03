require 'spec_helper'

describe 'test::classes_used' do
  it { should include_class('test::bare_class') }
  it { should_not include_class('test::parameterised_class') }

  it { should contain_class('test::parameterised_class').with_text('bar') }
  it { should_not contain_class('test::bare_class') }
end
