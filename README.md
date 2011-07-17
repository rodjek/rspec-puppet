# RSpec tests for your Puppet manifests

This is a work in progress.

## Using
To test that

    sysctl { 'baz'
      value => 'foo',
    }

Will cause the following resource to be in included in catalogue for a host

    exec { 'sysctl/reload':
      command => '/sbin/sysctl -p /etc/sysctl.conf',
    }

We can write the following testcase

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

