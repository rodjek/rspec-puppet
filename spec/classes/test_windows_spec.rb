# frozen_string_literal: true

require 'spec_helper'

describe 'test::windows' do
  let(:facts) { { operatingsystem: 'windows' } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file('C:\\something.txt') }
end
