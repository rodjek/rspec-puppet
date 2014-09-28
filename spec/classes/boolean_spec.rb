require 'spec_helper'

if Puppet::PUPPETVERSION !~ /0\.2/
  describe 'boolean' do
    let(:title) { 'bool.testing' }
    let(:params) { { :bool => false } }
  
    it { is_expected.to create_notify("bool testing")\
      .with_message("This will print when \$bool is false.") }
  end
end
