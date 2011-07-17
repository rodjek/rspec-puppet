# RSpec tests for your Puppet manifests

This is a work in progress.

## Using
    require 'puppet-rspec'

    RSpec.configure do |c|
      c.include PuppetRSpec
    end

    describe 'sysctl' do
      let(:node) { 'testhost.example.com' }
      let(:name) { 'baz' }
      let(:params) { { :value => 'foo' } }

      before(:all) do
        @c = catalogue_for('sysctl', params, '/path/to/puppet/modules')
      end
      subject { @c }

      it { should create_exec('sysctl/reload') }
      it { should create_exec('sysctl/reload').with_command("/sbin/sysctl -p /etc/sysctl.conf'") }
    end

