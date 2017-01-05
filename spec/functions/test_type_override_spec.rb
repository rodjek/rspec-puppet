require 'spec_helper'

# :type should override the type inferred from the file's location in spec/functions/
describe 'test::bare_class', :type => :class, :if => RSpec::Version::STRING >= '3' do
  it { should compile.with_all_deps }
end
