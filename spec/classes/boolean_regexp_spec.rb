require 'spec_helper'

describe 'boolean_test' do
  let(:title) { 'bool.testing' }
  let(:params) { { :bool => false } }
  let(:message_re) { %r{bool is false} }

  it { should create_notify('bool testing').with_message(message_re) }

  # `should_not with_messsage` == `should without_message`
  it { should_not create_notify('bool testing').with_message(%r{true}) }
  it { should create_notify('bool testing').without_message(%r{true}) }
end
