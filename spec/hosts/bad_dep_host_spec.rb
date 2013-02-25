require 'spec_helper'

describe 'bad_dep_host' do
  it { should_not compile.with_all_deps }
end
