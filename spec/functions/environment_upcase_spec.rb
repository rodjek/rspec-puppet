require 'spec_helper'

describe 'environment::upcase' do
  it { should run.with_params('aaa').and_return('AAA') }
end
