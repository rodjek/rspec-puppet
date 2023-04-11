# frozen_string_literal: true

require 'spec_helper'

describe 'test::windows' do
  let(:facts) { { operatingsystem: 'windows' } }

  let(:symlink_path) do
    RUBY_VERSION == '1.8.7' ? 'C:\\\\something.txt' : 'C:\\something.txt'
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file(symlink_path) }
end
