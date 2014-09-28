require 'spec_helper'

describe 'good_dep_host' do
  it { is_expected.to compile.with_all_deps }
end
