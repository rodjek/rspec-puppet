require 'spec_helper'

describe 'regsubst' do
  # used to test the fact that expected result can be a regexp
  it { should run.with_params('thisisatest', '^192', '254').and_return(/sat/) }
  it { should run.with_params('thisisatest', 'sat', 'xyz').and_return(/ixyze/) }
  it { should run.with_params('thisisatest', 'sat', 'xyz').and_return('thisixyzest') }
  it { should run.with_params('thisisatest', 'sat', 'xyz').and_return(/^thisixyzest$/) }
end
