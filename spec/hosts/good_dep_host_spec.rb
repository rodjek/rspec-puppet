require 'spec_helper'

describe 'good_dep_host' do
  it { should compile.with_all_deps }
end
