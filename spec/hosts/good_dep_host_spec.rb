# frozen_string_literal: true

require 'spec_helper'

describe 'good_dep_host' do
  let(:facts) { { 'operatingsystem' => 'Debian' } }

  it { is_expected.to compile.with_all_deps }
end
