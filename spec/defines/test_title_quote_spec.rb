require 'spec_helper'

describe 'test::notify' do
  let(:title) { "test'" }

  it { should contain_notify("test'") }
end
