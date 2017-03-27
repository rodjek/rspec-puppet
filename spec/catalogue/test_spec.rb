require 'spec_helper'

describe 'test.json' do
  it { should contain_notify('foo') }
end
