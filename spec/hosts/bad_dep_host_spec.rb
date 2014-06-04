require 'spec_helper'

describe 'bad_dep_host' do
  it { is_expected.not_to compile.with_all_deps }
end
