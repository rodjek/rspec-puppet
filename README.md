# RSpec tests for your Puppet manifests & modules

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
           |     |
           |     +-- <define_name>_spec.rb
           |
           +-- functions
           |     |
           |     +-- <function_name>_spec.rb
           |
           +-- hosts
                 |
                 +-- <host_name>_spec.rb

## Example groups

If you use the above directory structure, your examples will automatically be
placed in the correct groups and have access to the custom matchers.  *If you
choose not to*, you can force the examples into the required groups as follows.

```ruby
describe 'myclass', :type => :class do
  ...
end

describe 'mydefine', :type => :define do
  ...
end

describe 'myfunction', :type => :puppet_function do
  ...
end

describe 'myhost.example.com', :type => :host do
  ...
end
```

## Defined Types & Classes

### Matchers

#### Checking if a class has been included

You can test if a class has been included in the catalogue with the
`include_class` matcher.  It takes the class name as a string as its only
argument

```ruby
it { should include_class('foo') }
```

#### Checking if a resource exists

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

You can use the `with` method to verify the value of multiple parameters.

```ruby
it do should contain_service('keystone').with(
  'ensure'     => 'running',
  'enable'     => 'true',
  'hasstatus'  => 'true',
  'hasrestart' => 'true'
) end
```

You can also test that specific parameters have been left undefined with the
generic `without_<parameter>` chains.

```ruby
it { should contain_file('/foo/bar').without_mode }
```

You can use the without method to verify that a list of parameters have not been
defined

```ruby
it { should contain_service('keystone').without(
  ['restart', 'status']
)}
```

### Writing tests

#### Basic test structure

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

#### Specifying the title of a resource

```ruby
let(:title) { 'foo' }
```

#### Specifying the parameters to pass to a resources or parametised class

```ruby
let(:params) { {:ensure => 'present', ...} }
```

#### Specifying the FQDN of the test node

If the manifest you're testing expects to run on host with a particular name,
you can specify this as follows

```ruby
let(:node) { 'testhost.example.com' }
```

#### Specifying the facts that should be available to your manifest

By default, the test environment contains no facts for your manifest to use.
You can set them with a hash

```ruby
let(:facts) { {:operatingsystem => 'Debian', :kernel => 'Linux', ...} }
```

#### Specifying the exported resources that should be available to your manifest

By default, the test environment contains no exported resources for your
manifest to use. You can set them with a hash:

```ruby
let(:exported_resources) {
  {
    'host' => {
      'mock1.example.com' => {
        :ip => '127.0.0.1',
      },
      'mock2.example.com' => {
        :ip => '127.0.0.1',
      }
    },
    'user' => {
      'mockuser' => {
        :uid => '1337',
      }
    }
  }
}
```

#### Specifying the path to find your modules

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

## Functions

### Matchers

All of the standard RSpec matchers are available for you to use when testing
Puppet functions.

```ruby
it 'should be able to do something' do
  subject.call('foo') == 'bar'
end
```

For your convenience though, a `run` matcher exists to provide easier to
understand test cases.

```ruby
it { should run.with_params('foo').and_return('bar') }
```

### Writing tests

#### Basic test structure

```ruby
require 'spec_helper'

describe '<function name>' do
  ...
end
```

#### Specifying the name of the function to test

The name of the function must be provided in the top level description, e.g.

```ruby
describe 'split' do
```

#### Specifying the arguments to pass to the function

You can specify the arguments to pass to your function during the test(s) using
either the `with_params` chain method in the `run` matcher

```ruby
it { should run.with_params('foo', 'bar', ['baz']) }
```

Or by using the `call` method on the subject directly

```ruby
it 'something' do
  subject.call('foo', 'bar', ['baz'])
end
```

#### Testing the results of the function

You can test the result of a function (if it produces one) using either the
`and_returns` chain method in the `run` matcher

```ruby
it { should run.with_params('foo').and_return('bar') }
```

Or by using any of the existing RSpec matchers on the subject directly

```ruby
it 'something' do
  subject.call('foo') == 'bar'
  subject.call('baz').should be_an Array
end
```

#### Testing the errors thrown by the function

You can test whether the function throws an exception using either the
`and_raises_error` chain method in the `run` matcher

```ruby
it { should run.with_params('a', 'b').and_raise_error(Puppet::ParseError) }
it { should_not run.with_params('a').and_raise_error(Puppet::ParseError) }
```

Or by using the existing `raises_error` RSpec matcher

```ruby
it 'something' do
  expect { subject.call('a', 'b') }.should raise_error(Puppet::ParseError)
  expect { subject.call('a') }.should_not raise_error(Puppet::ParseError)
end
```
