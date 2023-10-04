# frozen_string_literal: true

require 'spec_helper'

describe 'deferred' do
  it { is_expected.to contain_notify('deferred msg').with_message('A STRING') }
end
