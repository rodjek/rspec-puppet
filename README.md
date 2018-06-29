# RSpec tests for your Puppet manifests & modules
[![Build Status](https://travis-ci.org/rodjek/rspec-puppet.svg?branch=master)](https://travis-ci.org/rodjek/rspec-puppet)
[![Coverage Status](https://coveralls.io/repos/rodjek/rspec-puppet/badge.svg?branch=master)](https://coveralls.io/r/rodjek/rspec-puppet?branch=master)

## Installation

    gem install rspec-puppet

> Note for ruby 1.8 users:  while rspec-puppet itself supports ruby 1.8, you'll
> need to pin rspec itself to `~> 3.1.0`, as later rspec versions do not work
> on old rubies anymore.

## Starting out with a new module

When you start out on a new module, create a metadata.json file for your module and then run `rspec-puppet-init` to create the necessary files to configure rspec-puppet for your module's tests.


## Configure manifests for Puppet 4

With Puppet 3, the manifest is set to `$manifestdir/site.pp`. However Puppet 4 defaults to an empty value. In order to test manifests you will need to set appropriate settings.

Puppet configuration reference for `manifest` can be found online:

* Puppet 3: https://docs.puppet.com/puppet/3.8/reference/configuration.html#manifest
* Puppet 4: https://docs.puppet.com/puppet/4.8/reference/configuration.html#manifest

Configuration is typically done in a `spec/spec_helper.rb` file which each of your spec will require. Example code:
```ruby
# /spec
base_dir = File.dirname(File.expand_path(__FILE__))

RSpec.configure do |c|
  c.module_path     = File.join(base_dir, 'fixtures', 'modules')
  c.manifest_dir    = File.join(base_dir, 'fixtures', 'manifests')
  c.manifest        = File.join(base_dir, 'fixtures', 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')

  # Coverage generation
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
```

## Configuration

rspec-puppet can be configured by modifying the `RSpec.configure` block in your
`spec/spec_helper.rb` file.

```
RSpec.configure do |c|
  c.<config option> = <value>
end
```

#### manifest\_dir
Type   | Default  | Puppet Version(s)
------ | -------- | -----------------
String | Required | 2.x, 3.x

The path to the directory containing your basic manifests like `site.pp`.

#### module\_path
Type   | Default  | Puppet Version(s)
------ | -------- | ------------------
String | Required | 2.x, 3.x, 4.x, 5.x

The path to the directory containing your Puppet modules.

#### default\_facts
Type | Default | Puppet Version(s)
---- | ------- | ------------------
Hash | `{}`    | 2.x, 3.x, 4.x, 5.x

A hash of default facts that should be used for all the tests.

#### hiera\_config
Type   | Default       | Puppet Version(s)
------ | ------------- | -----------------
String | `"/dev/null"` | 3.x, 4.x, 5.x

The path to your `hiera.yaml` file (if used).

#### default\_node\_params
Type | Default | Puppet Version(s)
---- | ------- | -----------------
Hash | `{}`    | 4.x, 5.x

A hash of default node parameters that should be used for all the tests.

#### default\_trusted\_facts
Type | Default | Puppet Version(s)
---- | ------- | -----------------
Hash | `{}`    | 4.x, 5.x

A hash of default trusted facts that should be used for all the tests
(available in the manifests as the `$trusted` hash). In order to use this, the
`trusted_node_data` setting must be set to `true`.

#### trusted\_node\_data
Type    | Default | Puppet Version(s)
------- | ------- | -----------------
Boolean | `false` | >=3.4, 4.x, 5.x

Configures rspec-puppet to use the `$trusted` hash when compiling the
catalogues.

#### trusted\_server\_facts
Type    | Default | Puppet Version(s)
------- | ------- | -----------------
Boolean | `false` | >=4.3, 5.x

Configures rspec-puppet to use the `$server_facts` hash when compiling the
catalogues.

#### confdir
Type   | Default         | Puppet Version(s)
------ | --------------- | ------------------
String | `"/etc/puppet"` | 2.x, 3.x, 4.x, 5.x

The path to the main Puppet configuration directory.

#### config
Type   | Default                | Puppet Version(s)
------ | ---------------------- | ------------------
String | Puppet's default value | 2.x, 3.x, 4.x, 5.x

The path to `puppet.conf`.

#### manifest
Type   | Default                | Puppet Version(s)
------ | ---------------------- | -----------------
String | Puppet's default value | 2.x, 3.x

The entry-point manifest for Puppet, usually `$manifest_dir/site.pp`.

#### template\_dir
Type   | Default | Puppet Version(s)
------ | ------- | -----------------
String | `nil`   | 2.x, 3.x

The path to the directory that Puppet should search for templates that are
stored outside of modules.

#### environmentpath
Type   | Default                               | Puppet Version(s)
------ | ------------------------------------- | -----------------
String | `"/etc/puppetlabs/code/environments"` | 4.x, 5.x

The search path for environment directories.

#### parser
Type   | Default     | Puppet Version(s)
------ | ----------- | -----------------
String | `"current"` | >= 3.2

This switches between the 3.x (`current`) and 4.x (`future`) parsers.

#### ordering
Type   | Default        | Puppet Version(s)
------ | -------------- | -----------------
String | `"title-hash"` | >= 3.3, 4.x, 5.x

How unrelated resources should be ordered when applying a catalogue.
 * `manifest` - Use the order in which the resources are declared in the
   manifest.
 * `title-hash` - Order the resources randomly, but in a consistent manner
   across runs (the order will only change if the manifest changes).
 * `random` - Order the resources randomly.

#### strict\_variables
Type    | Default | Puppet Version(s)
------- | ------- | -----------------
Boolean | `false` | >= 3.5, 4.x, 5.x

Makes Puppet raise an error when it tries to reference a variable that hasn't
been defined (not including variables that have been explicitly set to
`undef`).

#### stringify\_facts
Type    | Default | Puppet Version(s)
------- | ------- | -----------------
Boolean | `true`  | >= 3.3, 4.x, 5.x

Makes rspec-puppet coerce all the fact values into strings (matching the
behaviour of older versions of Puppet).

#### enable\_pathname\_stubbing
Type    | Default | Puppet Version(s)
------- | ------- | ------------------
Boolean |`false`  | 2.x, 3.x, 4.x, 5.x

Configures rspec-puppet to stub out `Pathname#absolute?` with it's own
implementation. This should only be enabled if you're running into an issue
running cross-platform tests where you have Ruby code (types, providers,
functions, etc) that use `Pathname#absolute?`.

#### setup\_fixtures
Type    | Default | Puppet Version(s)
------- | ------- | ------------------
Boolean | `true`  | 2.x, 3.x, 4.x, 5.x

Configures rspec-puppet to automatically create a link from the root of your
module to `spec/fixtures/<module name>` at the beginning of the test run.

#### derive\_node\_facts\_from\_nodename
Type    | Default | Puppet Version(s)
------- | ------- | -----------------
Boolean | `true`  | 2.x, 3.x, 4.x, 5.x

If `true`, rspec-puppet will override the `fdqn`, `hostname`, and `domain`
facts with values that it derives from the node name (specified with
`let(:node)`.

In some circumstances (e.g. where your nodename/certname is not the same as
your FQDN), this behaviour is undesirable and can be disabled by changing this
setting to `false`.

## Naming conventions

For clarity and consistency, I recommend that you use the following directory
structure and naming convention.

    module/
      ├── manifests/
      ├── lib/
      └── spec/
           ├── spec_helper.rb
           │
           ├── classes/
           │     └── <class_name>_spec.rb
           │
           ├── defines/
           │     └── <define_name>_spec.rb
           │
           ├── applications/
           │     └── <application_name>_spec.rb
           │
           ├── functions/
           │     └── <function_name>_spec.rb
           │
           ├── types/
           │     └── <type_name>_spec.rb
           │
           ├── type_aliases/
           │     └── <type_alias_name>_spec.rb
           │
           └── hosts/
                 └── <host_name>_spec.rb

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

describe 'myapplication', :type => :application do
  ...
end

describe 'myfunction', :type => :puppet_function do
  ...
end

describe 'mytype', :type => :type do
  ...
end

describe 'My::TypeAlias', :type => :type_alias do
  ...
end

describe 'myhost.example.com', :type => :host do
  ...
end
```

## Defined Types, Classes & Applications

### Matchers

#### Checking if the catalog compiles

You can test whether the subject catalog compiles cleanly with `compile`.

```ruby
it { is_expected.to compile }
```

To check the error messages of your class, you can check for raised error messages.

```ruby
it { is_expected.to compile.and_raise_error(/error message match/) }
```

#### Checking if a resource exists

You can test if a resource exists in the catalogue with the generic
`contain_<resource type>` matcher.

```ruby
it { is_expected.to contain_augeas('bleh') }
```

You can also test if a class has been included in the catalogue with the
same matcher.

```ruby
it { is_expected.to contain_class('foo') }
```

Note that rspec-puppet does none of the class name parsing and lookup that the puppet parser would do for you. The matcher only accepts fully qualified classnames without any leading colons. That is a class `foo::bar` will only be matched by `foo::bar`, but not by `::foo::bar`, or `bar` alone.

If your resource type includes :: (e.g.
`foo::bar` simply replace the :: with __ (two underscores).

```ruby
it { is_expected.to contain_foo__bar('baz') }
```

You can further test the parameters that have been passed to the resources with
the generic `with_<parameter>` chains.

```ruby
it { is_expected.to contain_package('mysql-server').with_ensure('present') }
```

If you want to specify that the given parameters should be the only ones passed
to the resource, use the `only_with_<parameter>` chains.

```ruby
it { is_expected.to contain_package('httpd').only_with_ensure('latest') }
```

You can use the `with` method to verify the value of multiple parameters.

```ruby
it do
  is_expected.to contain_service('keystone').with(
    'ensure'     => 'running',
    'enable'     => 'true',
    'hasstatus'  => 'true',
    'hasrestart' => 'true'
  )
end
```

The same holds for the `only_with` method, which in addition verifies the exact
set of parameters and values for the resource in the catalogue.

```ruby
it do
  is_expected.to contain_user('luke').only_with(
    'ensure' => 'present',
    'uid'    => '501'
  )
end
```

You can also test that specific parameters have been left undefined with the
generic `without_<parameter>` chains.

```ruby
it { is_expected.to contain_file('/foo/bar').without_mode }
```

You can use the without method to verify that a list of parameters have not been
defined

```ruby
it { is_expected.to contain_service('keystone').without(
  ['restart', 'status']
)}
```

#### Checking the number of resources

You can test the number of resources in the catalogue with the
`have_resource_count` matcher.

```ruby
it { is_expected.to have_resource_count(2) }
```

The number of classes in the catalogue can be checked with the
`have_class_count` matcher.

```ruby
it { is_expected.to have_class_count(2) }
```

You can also test the number of a specific resource type, by using the generic
`have_<resource type>_resource_count` matcher.

```ruby
it { is_expected.to have_exec_resource_count(1) }
```

This last matcher also works for defined types. If the resource type contains
::, you can replace it with __ (two underscores).

```ruby
it { is_expected.to have_logrotate__rule_resource_count(3) }
```

*NOTE*: when testing a class, the catalogue generated will always contain at
least one class, the class under test. The same holds for defined types, the
catalogue generated when testing a defined type will have at least one resource
(the defined type itself).

#### Relationship matchers

The following methods will allow you to test the relationships between the resources in your catalogue, regardless of how the relationship is defined. This means that it doesn’t matter if you prefer to define your relationships with the metaparameters (**require**, **before**, **notify** and **subscribe**) or the chaining arrows (**->**, **~>**, **<-** and **<~**), they’re all tested the same.

```ruby
it { is_expected.to contain_file('foo').that_requires('File[bar]') }
it { is_expected.to contain_file('foo').that_comes_before('File[bar]') }
it { is_expected.to contain_file('foo').that_notifies('File[bar]') }
it { is_expected.to contain_file('foo').that_subscribes_to('File[bar]') }
```

An array can be used to test a resource for multiple relationships

```ruby
it { is_expected.to contain_file('foo').that_requires(['File[bar]', 'File[baz]']) }
it { is_expected.to contain_file('foo').that_comes_before(['File[bar]','File[baz]']) }
it { is_expected.to contain_file('foo').that_notifies(['File[bar]', 'File[baz]']) }
it { is_expected.to contain_file('foo').that_subscribes_to(['File[bar]', 'File[baz]']) }
```

You can also test the reverse direction of the relationship, so if you have the following bit of Puppet code

```ruby
notify { 'foo': }
notify { 'bar':
  before => Notify['foo'],
}
```

You can test that **Notify[bar]** comes before **Notify[foo]**

```ruby
it { is_expected.to contain_notify('bar').that_comes_before('Notify[foo]') }
```
Or, you can test that **Notify[foo]** requires **Notify[bar]**

```ruby
it { is_expected.to contain_notify('foo').that_requires('Notify[bar]') }
```

##### Match target syntax

Note that this notation does not support any of the features you're used from the puppet language. Only a single resource with a single, unquoted title can be referenced here. Class names need to be always fully qualified and not have the leading `::`. It currently does not support inline arrays or quoting.

These work
* `Notify[foo]`
* `Class[profile::apache]`

These will not work
* `Notify['foo']`
* `Notify[foo, bar]`
* `Class[::profile::apache]`

##### Recursive dependencies

The relationship matchers are recursive in two directions:

* vertical recursion, which checks for dependencies with parents of the resource
 (i.e. the resource is contained, directly or not, in the class involved in the relationship).
 E.g. where `Package['foo']` comes before `File['/foo']`:

```puppet
class { 'foo::install': } ->
class { 'foo::config': }

class foo::install {
  package { 'foo': }
}

class foo::config {
  file { '/foo': }
}
```

* horizontal recursion, which follows indirect dependencies (dependencies of dependencies).
 E.g. where `Yumrepo['foo']` comes before `File['/foo']`:

```puppet
class { 'foo::repo': } ->
class { 'foo::install': } ->
class { 'foo::config': }

class foo::repo {
  yumrepo { 'foo': }
}

class foo::install {
  package { 'foo': }
}

class foo::config {
  file { '/foo': }
}
```

##### Autorequires

Autorequires are considered in dependency checks.

#### Type matcher

When testing custom types, the `be_valid_type` matcher provides a range of expectations:

* `with_provider(<provider_name>)`: check that the right provider was selected
* `with_properties(<property_list>)`: check that the specified properties are available
* `with_parameters(<parameter_list>)`: check that the specified parameters are available
* `with_features(<feature_list>)`: check that the specified features are available
* `with_set_attributes(<param_value_hash>)`: check that the specified attributes are set

#### Type alias matchers

When testing type aliases, the `allow_value` and `allow_values` matchers are used to check if the
alias accepts particular values or not:


```ruby
describe 'MyModule::Shape' do
  it { is_expected.to allow_value('square') }
  it { is_expected.to allow_values('circle', 'triangle') }
  it { is_expected.not_to allow_value('blue') }
end
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
  let(:params) { { 'value' => 'foo' } }

  it { is_expected.to contain_exec('sysctl/reload').with_command("/sbin/sysctl -p /etc/sysctl.conf") }
end
```

#### Specifying the title of a resource

```ruby
let(:title) { 'foo' }
```

#### Specifying the parameters to pass to a resources or parameterised class

Parameters of a defined type, class or application can be passed defining `:params` in a let,
and passing it a hash as seen below.

```ruby
let(:params) { {'ensure' => 'present', ...} }
```

For passing Puppet's `undef` as a paremeter value, you can simply use `:undef` and it will
be translated to `undef` when compiling. For example:

```ruby
let(:params) { {'user' => :undef, ...} }
```

For references to nodes or resources as seen when using `require` or `before` properties,
or an `application` resource you can pass the string as an argument to the `ref` helper:

```ruby
let(:params) { 'require' => ref('Package', 'sudoku') }
```

Which translates to:

```puppet
mydefine { 'mytitle': require => Package['sudoku'] }
```

Another example, for an application setup (when using `app_management`):

```ruby
let(:params) { { 'nodes' => { ref('Node', 'dbnode') => ref('Myapp::Mycomponent', 'myapp') } } }
```

Will translate to:

```puppet
site { myapp { 'myimpl': nodes => { Node['dbnode'] => Myapp::Mycomponent['myimpl'] } } }
```

#### Specifying the FQDN of the test node

If the manifest you're testing expects to run on host with a particular name,
you can specify this as follows

```ruby
let(:node) { 'testhost.example.com' }
```

#### Specifying the environment name

If the manifest you're testing expects to evaluate the environment name,
you can specify this as follows

```ruby
let(:environment) { 'production' }
```

#### Specifying the facts that should be available to your manifest

By default, the test environment contains no facts for your manifest to use.
You can set them with a hash

```ruby
let(:facts) { {'operatingsystem' => 'Debian', 'kernel' => 'Linux', ...} }
```

Facts may be expressed as a value (shown in the previous example) or a structure.  Fact keys
may be expressed as either symbols or strings.  A key will be converted to a lower case
string to align with the Facter standard

```ruby
let(:facts) { {'os' => { 'family' => 'RedHat', 'release' => { 'major' => '7', 'minor' => '1', 'full' => '7.1.1503' } } } }
```

You can also create a set of default facts provided to all specs in your spec_helper:

``` ruby
RSpec.configure do |c|
  c.default_facts = {
    'operatingsystem' => 'Ubuntu'
  }
end
```

Any facts you provide with `let(:facts)` in a spec will automatically be merged on top
of the default facts.

#### Specifying top-scope variables that should be available to your manifest

You can create top-scope variables much in the same way as an ENC.


```ruby
let(:node_params) { { 'hostgroup' => 'webservers', 'rack' => 'KK04', 'status' => 'maintenance' } }
```

You can also create a set of default top-scope variables provided to all specs in your spec_helper:

``` ruby
RSpec.configure do |c|
  c.default_node_params = {
    'owner'  => 'itprod',
    'site'   => 'ams4',
    'status' => 'live'
  }
end
```

**NOTE** Setting top-scope variables is not supported in Puppet < 3.0.

#### Specifying extra code to load (pre-conditions)

If the manifest being tested relies on another class or variables to be set, these can be added via
a pre-condition. This code will be evaluated before the tested class.

```ruby
let(:pre_condition) { 'include other_class' }
```

This may be useful when testing classes that are modular, e.g. testing `apache::mod::foo` which
relies on a top-level `apache` class being included first.

The value may be a raw string to be inserted into the Puppet manifest, or an array of strings
(manifest fragments) that will be concatenated.

#### Specifying extra code to load (post-conditions)

In some cases, you may need to ensure that the code that you are testing comes
**before** another set of code. Similar to the `:pre_condition` hook, you can add
a `:post_condition` hook that will ensure that the added code is evaluated
**after** the tested class.

```ruby
let(:post_condition) { 'include other_class' }
```

This may be useful when testing classes that are modular, e.g. testing class
`do_strange_things::to_the_catalog` which must come before class ``foo``.

The value may be a raw string to be inserted into the Puppet manifest, or an
array of strings (manifest fragments) that will be concatenated.

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

#### Specifying trusted facts

When testing with Puppet >= 4.3 the trusted facts hash will have the standard trusted fact keys
(certname, domain, and hostname) populated based on the node name (as set with `:node`).

By default, the test environment contains no custom trusted facts (as usually obtained
from certificate extensions) and found in the `extensions` key. If you need to test against
specific custom certificate extensions you can set those with a hash. The hash will then
be available in `$trusted['extensions']`

```ruby
let(:trusted_facts) { {'pp_uuid' => 'ED803750-E3C7-44F5-BB08-41A04433FE2E', '1.3.6.1.4.1.34380.1.2.1' => 'ssl-termination'} }
```

You can also create a set of default certificate extensions provided to all specs in your spec_helper:

```ruby
RSpec.configure do |c|
  c.default_trusted_facts = {
    'pp_uuid'                 => 'ED803750-E3C7-44F5-BB08-41A04433FE2E',
    '1.3.6.1.4.1.34380.1.2.1' => 'ssl-termination'
  }
end
```

#### Testing Exported Resources

You can test if a resource was exported from the catalogue by using the
`exported_resources` accessor in combination with any of the standard matchers.

You can use `exported_resources` as the subject of a child context:

```ruby
context 'exported resources' do
  subject { exported_resources }

  it { is_expected.to contain_file('foo') }
end
```

You can also use `exported_resources` directly in a test:

```ruby
it { expect(exported_resources).to contain_file('foo') }
```

#### Testing applications

Applications in some ways behave as defined resources, but are more complex so
require a number of elements already documented above to be combined for testing.

A full example of the simplest rspec test for a single component application:

```ruby
require 'spec_helper'

describe 'orch_app' do
  let(:node) { 'my_node' }
  let(:title) { 'my_awesome_app' }
  let(:params) do
    {
      'nodes' => {
        ref('Node', node) => ref('Orch_app::Db', title),
      }
    }
  end

  it { should compile }
  it { should contain_orch_app(title) }
end
```

Each piece is required:

* You must turn on app_management during testing for the handling to work
* The `:node` definition is required to be set so later on you can reference it in the `:nodes` argument within `:params`
* Applications act like defined resources, and each require a `:title` to be defined
* The `:nodes` key in `:params` requires the use of node reference mappings to resource
  mappings. The `ref` keyword allows you to provide these (a normal string will not work).

Beyond these requirements, the very basic `should compile` test and other matchers
as you would expect will work the same as classes and defined resources.

**Note:** for the moment, cross-node support is not available and will return an error.
Ensure you model your tests to be single-node for the time being.

## Functions

### Matchers

All of the standard RSpec matchers are available for you to use when testing
Puppet functions.

```ruby
it 'should be able to do something' do
  subject.call(['foo']) == 'bar'
end
```

For your convenience though, a `run` matcher exists to provide easier to
understand test cases.

```ruby
it { is_expected.to run.with_params('foo').and_return('bar') }
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
it { is_expected.to run.with_params('foo', 'bar', ['baz']) }
```

Or by using the `call` method on the subject directly

```ruby
it 'something' do
  subject.call(['foo', 'bar', ['baz']])
end
```

#### Passing lambdas to the function

A lambda (block) can be passed to functions that support either a required or
optional lambda by passing a block to the `with_lambda` chain method in the
`run` matcher.

```ruby
it { is_expected.to run.with_lambda { |x| x * 2 }
```

#### Testing the results of the function

You can test the result of a function (if it produces one) using either the
`and_returns` chain method in the `run` matcher

```ruby
it { is_expected.to run.with_params('foo').and_return('bar') }
```

Or by using any of the existing RSpec matchers on the subject directly

```ruby
it 'something' do
  subject.call(['foo']) == 'bar'
  subject.call(['baz']).should be_an Array
end
```

#### Testing the errors thrown by the function

You can test whether the function throws an exception using either the
`and_raises_error` chain method in the `run` matcher

```ruby
it { is_expected.to run.with_params('a', 'b').and_raise_error(Puppet::ParseError) }
it { is_expected.not_to run.with_params('a').and_raise_error(Puppet::ParseError) }
```

Or by using the existing `raises_error` RSpec matcher

```ruby
it 'something' do
  expect { subject.call(['a', 'b']) }.should raise_error(Puppet::ParseError)
  expect { subject.call(['a']) }.should_not raise_error(Puppet::ParseError)
end
```

#### Accessing the parser scope where the function is running

Some complex functions require access to the current parser's scope, e.g. for
stubbing other parts of the system.

```ruby
before(:each) { scope.expects(:lookupvar).with('some_variable').returns('some_value') }
it { is_expected.to run.with_params('...').and_return('...') }
```

Note that this does not work when testing manifests which use custom functions. Instead,
you'll need to create a replacement function directly.

```ruby
before(:each) do
    Puppet::Parser::Functions.newfunction(:custom_function, :type => :rvalue) { |args|
        raise ArgumentError, 'expected foobar' unless args[0] == 'foobar'
        'expected value'
    }
end

```


## Hiera integration

### Configuration

Set the hiera config symbol properly in your spec files:

```ruby
let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')
```

Create your spec hiera files

spec/fixtures/hiera/hiera.yaml
```ruby
---
:backends:
  - yaml
:hierarchy:
  - test
:yaml:
  :datadir: 'spec/fixtures/hiera'
```

spec/fixtures/hiera/test.yaml
```ruby
---
ntpserver: ['ntp1.domain.com','ntpXX.domain.com']
user:
  oneuser:
    shell: '/bin/bash'
  twouser:
    shell: '/sbin/nologin'
```

### Use hiera in your tests

```ruby
  ntpserver = hiera.lookup('ntpserver', nil, nil)
  let(:params) { 'ntpserver' => ntpserver }
```

### Enabling hiera lookups
If you just want to fetch values from hiera (e.g. because
you're testing code that uses explicit hiera lookups) just specify
the path to the hiera config in your `spec_helper.rb`

```ruby
RSpec.configure do |c|
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
end
```

spec/fixtures/hiera/hiera.yaml
```yaml
---
:backends:
  - yaml
:yaml:
  :datadir: spec/fixtures/hieradata
:hierarchy:
  - common
```

**Please note:** In-module hiera data depends on having a correct metadata.json file. It is
strongly recommended that you use [metadata-json-lint](https://github.com/voxpupuli/metadata-json-lint)
to automatically check your metadata.json file before running rspec.

## Producing coverage reports

You can output a basic resource coverage report with the following in
your `spec_helper.rb`

```ruby
RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
```

This checks which Puppet resources have been explicitly checked as part
of the current test run and outputs both a coverage percentage and a
list of untouched resources.

A desired code coverage level can be provided. If this level is not achieved, a test failure will be raised.  This can be used with a CI service, such as Jenkins or Bamboo, to enforce code coverage.  The following example requires the code coverage to be at least 95%.

```ruby
RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(95)
  end
end
```

Resources declared outside of the module being tested (i.e. forge dependencies)
are automatically removed from the coverage report. There is one exception for
this though: **prior to Puppet 4.6.0**, resources created by functions
(create\_resources(), ensure\_package(), etc) did not have the required
information in them to determine which manifest they came from and so can not
be excluded from the coverage report.

## Related projects

* [puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper): shared spec helpers to setup puppet
* [rspec-puppet-augeas](https://github.com/domcleal/rspec-puppet-augeas): RSpec tests for Augeas resources inside Puppet manifests
* [jimdo-rspec-puppet-helpers](https://github.com/Jimdo/jimdo-rspec-puppet-helpers): Tests the contents of a file with a source
* Ease development of specs
  * [puppet-catalog_rspec](https://github.com/enterprisemodules/puppet-catalog_rspec): Dump the Puppet Catalog as RSpec code at compile time
  * [create_specs](https://github.com/alexharv074/create_specs.git): A different implementation that takes a compiled catalog and writes out RSpec code with various options
* Fact providers
  * [rspec-puppet-facts](https://github.com/mcanevet/rspec-puppet-facts): Simplify your unit tests by looping on every supported Operating System and populating facts.
  * [rspec-puppet-osmash](https://github.com/Aethylred/rspec-puppet-osmash): Provides Operation System hashes and validations for rspec-puppet
  * [puppet_spec_facts](https://github.com/danieldreier/puppet_spec_facts): Gem to provide puppet fact hashes for rspec-puppet testing

For a list of other module development tools see https://puppet.community/plugins/
