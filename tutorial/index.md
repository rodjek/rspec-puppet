---
layout: minimal
---

# Tutorial

## About rspec-puppet

### Why should you test your Puppet modules?
At first glance, writing tests for your Puppet modules appears to be no more
than simply duplicating your manifests in a different language and, for basic 
"package/file/service" modules, it is.

However, when you start leveling up your modules to include dynamic content
from templates, support multiple operating systems or take different actions
when passed parameters, these tests become invaluable when adding new
functionality to your modules, protecting against regressions when refactoring
or upgrading to a new Puppet release.

### What should you be testing?
There are a lot of people confused by the purpose of these tests as they can't
test the result of the manifest on a live system.  That is not the point of
rspec-puppet.

Rspec-puppet tests are there to test the behaviour of Puppet when it compiles 
your manifests into a catalogue of Puppet resources.  For example, you might
want to test that your `apache::vhost` defined type creates a `file` resource
with a `path` of `/etc/apache2/sites-available/foo` when run on a Debian host.

When writing your test cases, you should only test the first level of resources
in your manifest.  By this I mean, when testing your 'webserver' role class,
you would test for the existence of the `apache::vhost` types, but not for the
`file` resources created by them, that's the job of the tests for
`apache::vhost`.

## Writing tests

First thing's first, if you haven't setup your module for rspec-puppet, follow
[these instructions](/setup/) before continuing.

### Basic structure of a test file
Whether you're testing classes, defined types, hosts or functions the structure
of a your test file is always the same

{% highlight ruby %}
require 'spec_helper'

describe '<name of the thing being tested>' do
  # Your tests go in here
end
{% endhighlight %}

The important thing is what you name your test file and where you put it.  Test
files should always end in `_spec.rb` (generally, they're named `<thing being
tested>_spec.rb`). Class tests should be placed in `spec/classes`, defined type
tests should go in `spec/defines`, host tests should be placed in `spec/hosts`
and function tests should go in `spec/functions`.

### Writing your first test cases

_This is not intended to be an RSpec tutorial, just an explanation of how to
use the extended functionality that rspec-puppet provides.  If you are not
familiar with the basics of RSpec, I highly recommend you take a couple of
minutes before continuing to read through the [RSpec
documentation](https://www.relishapp.com/rspec)_

Lets say you're writing tests for a `logrotate::rule` type that does two
things:

 1. Includes the `logrotate::setup` class which handles installing logrotate
 2. A `file` resource that drops your logrotate rule into `/etc/logrotate.d`

First off, lets create a skeleton spec file for your defined type
(`modules/logrotate/spec/defines/rule_spec.rb`)

{% highlight ruby %}
require 'spec_helper'

describe 'logrotate::rule' do

end
{% endhighlight %}

As this is a defined type, the first thing we need to do is give it a title
(the string after the `{` in your manifests).

{% highlight ruby %}
  let(:title) { 'nginx' }
{% endhighlight %}

Now, lets test that we're including that `logrotate::setup` class

{% highlight ruby %}
  it { is_expected.to contain_class('logrotate::setup') }
{% endhighlight %}

Remember, we don't want to test what `logrotate::setup` does, we'll leave that
to the test cases you're going to be writing for that class.

At this point, your spec file should look like this

{% highlight ruby %}
require 'spec_helper'

describe 'logrotate::rule' do
  let(:title) { 'nginx' }

  it { is_expected.to contain_class('logrotate::setup') }
end
{% endhighlight %}

OK, on to dealing with that `file` resource, lets use the title of the
`logrotate::rule` resource as the name of the file you're dropping into
`/etc/logrotate.d/`.

{% highlight ruby %}
  it { is_expected.to contain_file('/etc/logrotate.d/nginx') }
{% endhighlight %}

As it currently stands, this test is pretty useless as it doesn't actually
check anything about the file.  We can check values of the parameters passed to
the file resource by chaining the `with` method onto our test and passing it
a hash of expected parameters and values.  Lets say we want to set some sane
values: present, owned by root and read only:

{% highlight ruby %}
  it do 
    is_expected.to contain_file('/etc/logrotate.d/nginx').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0444',
    })
  end
{% endhighlight %}

You should now have a spec file that looks like this

{% highlight ruby %}
require 'spec_helper'

describe 'logrotate::rule' do
  let(:title) { 'nginx' }

  it { is_expected.to contain_class('logrotate::rule') }

  it do
    is_expected.to contain_file('/etc/logrotate.d/nginx').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0444',
    })
  end
end
{% endhighlight %}

What about the most important part of the file, its contents?  Before we get
to that, we're going to make your type take a boolean parameter called
`compress`.  If this value is `true`, a line containing `compress` should
exist in the file.  If this value is `false`, a line containing `nocompress`
should exist in the file.

{% highlight ruby %}
  context 'with compress => true' do
    let(:params) { {:compress => true} }

    it do
      is_expected.to contain_file('/etc/logrotate.d/nginx') \
        .with_content(/^\s*compress$/)
    end
  end

  context 'with compress => false' do
    let(:params) { {:compress => false} }

    it do
      is_expected.to contain_file('/etc/logrotate.d/nginx') \
        .with_content(/^\s*nocompress$/)
    end
  end
{% endhighlight %}

You'll note that we're now specifying the parameters that should be sent to our
`logrotate::rule` type by setting params to a hash.  Similarly, you can also
specify the value of facts by using `let(:facts) { }`.  The other thing we did
was chain a `with_content` method onto our test and passed it a regex that the
value should match.  You can do this with any other parameter as well, eg
`with_ensure`, `with_owner`, `with_foobarbaz`.

As our type can only handle two possible values for `compress`, let's be nice
and make sure that compilation will fail if someone passes something else to
it.

{% highlight ruby %}
  context 'with compress => foo' do
    let(:params) { {:compress => 'foo'} }

    it do
      expect {
        is_expected.to contain_file('/etc/logrotate.d/nginx')
      }.to raise_error(Puppet::Error, /compress must be true or false/)
    end
  end
{% endhighlight %}

The final version of your spec file should be:

{% highlight ruby %}
require 'spec_helper'

describe 'logrotate::rule' do
  let(:title) { 'nginx' }

  it { is_expected.to contain_class('logrotate::rule') }

  it do
    is_expected.to contain_file('/etc/logrotate.d/nginx').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0444',
    })
  end

  context 'with compress => true' do
    let(:params) { {:compress => true} }

    it do
      is_expected.to contain_file('/etc/logrotate.d/nginx') \
        .with_content(/^\s*compress$/)
    end
  end

  context 'with compress => false' do
    let(:params) { {:compress => false} }

    it do
      is_expected.to contain_file('/etc/logrotate.d/nginx') \
        .with_content(/^\s*nocompress$/)
    end
  end

  context 'with compress => foo' do
    let(:params) { {:compress => 'foo'} }

    it do
      expect {
        is_expected.to contain_file('/etc/logrotate.d/nginx')
      }.to raise_error(Puppet::Error, /compress must be true or false/)
    end
  end
end
{% endhighlight %}

Congratulations, you've just written a set of tests for a defined type without
writing a single line of Puppet code.  If you want to, go read some more about
the [matchers you just used](/matchers/).

Now go write the manifests needed to make these tests pass!

### Testing defined types & classes

#### Specifying parameters

If your parameterised class or defined type takes parameters, you can specify
their values with a hash.

{% highlight ruby %}
let(:params) { {:foo => 'bar', :baz => 'gronk'} }
{% endhighlight %}

#### Specifying the title of the defined type

As when using a defined type, when you're testing one it needs to have a title.

{% highlight ruby %}
let(:title) { 'foo' }
{% endhighlight %}

#### Specifying the FQDN of the test node

If you manifests depend upon the node having a certain name, you can specify
this as follows

{% highlight ruby %}
let(:node) { 'testhost.example.com' }
{% endhighlight %}

If you choose not to specify a name, the FQDN of the machine running the tests
will be used instead.

#### Specifying the facts available to your manifest

By default, the test environment contains only the `$::hostname`, `$::domain`
and `$::fqdn` facts.  If you want to specify additional facts, you can set them
as follows

{% highlight ruby %}
let(:facts) { {:operatingsystem => 'Debian', :ipaddress => '192.168.0.1'} }
{% endhighlight %}

### Testing hosts

Testing hosts is much the same as testing manifests and defined types, you just
create your spec file under `spec/hosts/`.

{% highlight ruby %}
require 'spec_helper'

describe 'testhost.example.com' do
  # your tests go here
end
{% endhighlight %}

This will look for a node definition in your `site.pp` for the named host,
compile it and run your tests over that catalogue.

### Testing functions

As with all other rspec-puppet tests, you have access to to all the standard
RSpec matchers, however a `run` matcher has been provided for your convenience.

{% highlight ruby %}
it { is_expected.to run.with_params('foo').and_return('bar') }
{% endhighlight %}

A very basic example spec file for testing a `to_lower` function would be
{% highlight ruby %}
require 'spec_helper'

describe 'to_lower' do
  it { is_expected.to run.with_params('FOO').and_return('foo') }
end
{% endhighlight %}
