require 'spec_helper'

describe 'boolean' do
  let(:title) { 'bool.testing' }
  let(:params) { { :bool => false } }
  let(:message_re) { /bool is false/ }

  it { is_expected.to create_notify("bool testing").with_message(message_re) }

  # `should_not with_messsage` == `should without_message`
  it { is_expected.not_to create_notify("bool testing").with_message(/true/) }
  it { is_expected.to create_notify("bool testing").without_message(/true/) }
end
