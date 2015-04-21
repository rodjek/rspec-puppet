require 'spec_helper'

if Puppet::PUPPETVERSION !~ /0\.2/
  describe 'boolean_test' do
    let(:title) { 'bool.testing' }
    let(:params) { { :bool => false } }
  
    it { should create_notify("bool testing")\
      .with_message("This will print when \$bool is false.") }
  end
end
