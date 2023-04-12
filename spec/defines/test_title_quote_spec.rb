# frozen_string_literal: true

require 'spec_helper'

describe 'test::notify' do
  let(:title) { "test'" }

  it { is_expected.to contain_notify("test'") }
end
