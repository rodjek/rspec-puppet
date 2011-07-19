# RSpec tests for your Puppet manifests

## Installation

    gem install rspec-puppet

## Naming conventions

For clarity and consistency, I recommend that you use the following directory
structure and naming convention.

    module
      |
      +-- manifests
      |
      +-- lib
      |
      +-- spec
           |
           +-- spec_helper.rb
           |
           +-- classes
           |     |
           |     +-- <class_name>_spec.rb
           |
           +-- defines
                 |
                 +-- <define_name>_spec.rb

## Example groups

If you use the above directory structure, your examples will automatically be
placed in the correct groups and have access to the custom matchers.  If you
choose not to, you can force the examples into the required groups as follows.

    describe 'myclass', :type => :class do
      ...
    end

    describe 'mydefine', :type => :define do
      ...
    end

## Matchers

### Checking if a class has been included

You can test if a class has been included in the catalogue with the
`include_class` matcher.  It takes the class name as a string as its only
argument

    it { should include_class('foo') }

### Checking if a resources exists

You can test if a resource exists in the catalogue with the generic
`creates_<resource type>` matcher.  If your resource type includes :: (e.g.
`foo::bar` simply replace the :: with -

    it { should create_augeas('bleh') }
    it { should create_foo-bar('baz') }

You can further test the parameters that have been passed to the resources with
the generic `with_<parameter>` chains.

    it { should create_package('mysql-server').with_ensure('present') }

## Writing tests

### Basic test structure

To test that

    sysctl { 'baz'
      value => 'foo',
    }

Will cause the following resource to be in included in catalogue for a host

    exec { 'sysctl/reload':
      command => '/sbin/sysctl -p /etc/sysctl.conf',
    }

We can write the following testcase

    describe 'sysctl' do
      let(:title) { 'baz' }
      let(:params) { { :value => 'foo' } }

      it { should create_exec('sysctl/reload').with_command("/sbin/sysctl -p /etc/sysctl.conf") }
    end

### Specifying the title of a resource

    let(:title) { 'foo' }

### Specifying the parameters to pass to a resources or parametised class

    let(:params) { {:ensure => 'present', ...} }

### Specifying the FQDN of the test node

If the manifest you're testing expects to run on host with a particular name,
you can specify this as follows

    let(:node) { 'testhost.example.com' }

### Specifying the facts that should be available to your manifest

By default, the test environment contains no facts for your manifest to use.
You can set them with a hash

    let(:facts) { {:operatingsystem => 'Debian', :kernel => 'Linux', ...} }

### Specifying the path to find your modules

I recommend setting a default module path by adding the following code to your
`spec_helper.rb`

    RSpec.configure do |c|
      c.module_path = '/path/to/your/module/dir'
    end

However, if you want to specify it in each example, you can do so

    let(:module_path) { '/path/to/your/module/dir' }
