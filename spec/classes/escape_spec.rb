require 'spec_helper'

describe 'escape' do
  let(:params) { { :content => '$MSG foo' } }

  it { should contain_file('/tmp/escape').with_content(/\$MSG foo/) }
end
