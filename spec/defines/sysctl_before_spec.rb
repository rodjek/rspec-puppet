require 'spec_helper'

describe 'sysctl::before' do
  let(:title) { 'sysctl::before' }
  let(:params) { { :value => "title" } }

  it "Should raise an error about needing the sysctl::common class" do
    expect { should create_notify("message-title")\
      .with_message("This should print if the class is here first.") }\
    .to raise_error(Puppet::Error, /Could not find resource 'Class\[Sysctl::Common\]/)
  end
end
  
describe 'sysctl::before' do
  let(:title) { 'test define' }
  let(:pre_condition) { 'class {"sysctl::common":}' }
  let(:params) { { :value => "title" } }

  it { should create_resource("sysctl::before", 'test define')\
    .with_param(:value, "title") }

  it { should include_class("sysctl::common") }

end
