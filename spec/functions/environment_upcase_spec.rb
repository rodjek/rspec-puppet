require 'spec_helper'

describe 'environment::upcase', :if => Puppet.version.to_i >= 4 do
  it { should run.with_params('aaa').and_return('AAA') }
end
