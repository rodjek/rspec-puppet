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

```ruby
describe 'myclass', :type => :class do
  ...
end

describe 'mydefine', :type => :define do
  ...
end
```

## Matchers

### Checking if a class has been included

You can test if a class has been included in the catalogue with the
`include_class` matcher.  It takes the class name as a string as its only
argument

```ruby
it { should include_class('foo') }
```

### Checking if a resources exists

You can test if a resource exists in the catalogue with the generic
`contain_<resource type>` matcher.

```ruby
it { should contain_augeas('bleh') }
```

If your resource type includes :: (e.g.
`foo::bar` simply replace the :: with __ (two underscores).

```ruby
it { should contain_foo__bar('baz') }
```

You can further test the parameters that have been passed to the resources with
the generic `with_<parameter>` chains.

```ruby
it { should contain_package('mysql-server').with_ensure('present') }
```

You can also test that specific parameters have been left undefined with the
generic `without_<parameter>` chains.

```ruby
it { should contain_file('/foo/bar').without_mode }
```

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

We can write the following testcase (in `spec/defines/sysctl_spec.rb`)

```ruby
describe 'sysctl' do
  let(:title) { 'baz' }
  let(:params) { { :value => 'foo' } }

  it { should contain_exec('sysctl/reload').with_command("/sbin/sysctl -p /etc/sysctl.conf") }
end
```

### Specifying the title of a resource

```ruby
let(:title) { 'foo' }
```

### Specifying the parameters to pass to a resources or parametised class

```ruby
let(:params) { {:ensure => 'present', ...} }
```

### Specifying the FQDN of the test node

If the manifest you're testing expects to run on host with a particular name,
you can specify this as follows

```ruby
let(:node) { 'testhost.example.com' }
```

### Specifying the facts that should be available to your manifest

By default, the test environment contains no facts for your manifest to use.
You can set them with a hash

```ruby
let(:facts) { {:operatingsystem => 'Debian', :kernel => 'Linux', ...} }
```

### Specifying the path to find your modules

I recommend setting a default module path by adding the following code to your
`spec_helper.rb`

```ruby
RSpec.configure do |c|
  c.module_path = '/path/to/your/module/dir'
end
```

However, if you want to specify it in each example, you can do so

```ruby
let(:module_path) { '/path/to/your/module/dir' }
```
