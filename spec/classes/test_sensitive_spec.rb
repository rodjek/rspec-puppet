# frozen_string_literal: true

require 'spec_helper'

describe 'test::sensitive' do
  it { is_expected.to contain_class('test::sensitive::user').with_password(sensitive('myPassword')) }
  it { is_expected.to contain_class('test::sensitive::user').with_password(sensitive(/Pass/)) }
end
