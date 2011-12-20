require 'spec_helper'

describe 'boolean' do
  let(:title) { 'bool.testing' }
  let(:params) { { :bool => false } }
  let(:message_re) { /bool is false/ }

  it { should create_notify("bool testing").with_message(message_re) }
  it { should_not create_notify("bool testing").with_message(/true/) }
end
