# frozen_string_literal: true

require 'spec_helper'

describe 'test::duplicate_alias' do
  let(:facts) { { 'operatingsystem' => 'Debian' } }

  it { is_expected.to compile }
  it { is_expected.to contain_exec('foo_bar_1') }
  it { is_expected.to contain_exec('foo_bar_2') }
  it { is_expected.not_to contain_exec('/bin/echo foo bar') }
end
