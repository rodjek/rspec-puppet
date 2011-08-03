require 'spec_helper'

describe 'boolean' do
  let(:title) { 'bool.testing' }
  let(:params) { { :bool => false } }
  
  it { should create_notify("bool testing")\
    .with_message("This will print when \$bool is false.") }

end
