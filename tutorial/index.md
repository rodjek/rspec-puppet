---
layout: minimal
---

# Tutorial

## About rspec-puppet

### Why should you test your Puppet modules?
At first glance, writing tests for your Puppet modules appears to be no more
than simply duplicating your manifests in a different language and for basic 
"package/file/service" modules, it is.

However, when you start leveling up your modules to include dynamic content
from templates, support multiple operating systems or take different actions
when passed parameters, these tests become invaluable when adding new
functionality to your modules, protecting against regressions when refactoring
or upgrading to a new Puppet release.

### What should you be testing?
There are a lot of people confused by the point of these tests as they can't
test the result of the manifest on a live system.  That is not the point of
rspec-puppet.

Rspec-puppet tests are there to test the behaviour of Puppet when it compiles 
your manifests into a catalogue of Puppet resources.  For example, you might
want to test that your `apache::vhost` defined type creates a `file` resource
with a `path` of `/etc/apache2/sites-available/foo` when run on a Debian host.

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

### Testing classes & defined types

### Testing hosts
Testing hosts is much the same as testing manifests and defined types.  It

### Testing functions

As with all other rspec-puppet tests, you have access to to all the standard
RSpec matchers, however a `run` matcher has been provided for your convenience.

{% highlight ruby %}
it { should run.with_params('foo').and_return('bar') }
{% endhighlight %}

A very basic example spec file for testing a `to_lower` function would be
{% highlight ruby %}
require 'spec_helper'

describe 'to_lower' do
  it { should run.with_params('FOO').and_return('foo') }
end
{% endhighlight %}
