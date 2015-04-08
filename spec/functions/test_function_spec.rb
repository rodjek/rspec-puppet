require 'spec_helper'

describe 'test_function', :if => Puppet.version.to_f >= 4.0 do
  # Verify that we can load functions from modules
  it { should run.with_params('foo').and_return(/value is foo/) }
end
