require 'spec_helper'

describe 'map_reduce', :if => (Puppet.version.to_f >= 4.0 || RSpec.configuration.parser == 'future') do
  let(:params) do
    {
     :values => [0, 1, 2]
    }
  end

  it { should compile.with_all_deps }

  it { should create_notify('joined_incremented_values').with_message('123') }
end
