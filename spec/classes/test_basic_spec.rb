require 'spec_helper'

describe 'test::basic' do
  it { should contain_fake('foo').with_three([{'foo' => 'bar'}]) }
end
