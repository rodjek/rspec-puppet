---
layout: minimal
---

# Matchers
## Classes, Defined Types and Hosts
### compile
This is the most basic test you can do on your manifest
 * Does it compile?
 * Are there no dependency cycles in the graph?

{% highlight ruby %}
it { should compile }
{% endhighlight %}

This matcher also has an optional method that you may want to use,
`with_all_deps`. This will check if all the resources you have specified
relationships to (with `require`, `notify`, `subscribe`, `before` or the
chaining arrows) also exist in the catalogue.

{% highlight ruby %}
it { should compile.with_all_deps }
{% endhighlight %}

You'll probably want to use this when testing host or role catalogues, but
perhaps not when testing individual modules that might reference other modules.

### contain_\*
In order to test that your manifest contains a particular Puppet resource, you
should use the generic `contain_<resource>` class.

{% highlight ruby %}
it { should contain_service('apache') }
{% endhighlight %}

If the resource type you're testing for contains `::` in it, replace the `::`
with `__` (two underscores).  For example, to test that your manifest contains
`apache::vhost` you would do

{% highlight ruby %}
it { should contain_apache__vhost('my awesome vhost') }
{% endhighlight %}

You can also test for the presence of Puppet classes in the same manner.

{% highlight ruby %}
it { should contain_class('apache') }
{% endhighlight %}

#### with\_\* and without\_\*
Further to this, you can test for the presence or absence of parameters on
these resources by chaining any number of `.with_<parameter>` or
`.without_<parameter>` methods onto the end of your test.  These methods can
either take an exact value, a regular expression or a Ruby Proc.

{% highlight ruby %}
it { should contain_service('mysql-server').with_ensure('present') }
it { should contain_file('/etc/logrotate.d/apache').with_content(/compress/) }
it { should contain_file('/etc/logrotate.d/apache').without_owner('root') }
{% endhighlight %}

#### only_with\_\*
If you want to test the presence of an exact set of parameters on your
resources, you can do so by chaining the `.only_with_<parameter>` methods.
These methods also take an exact value or a regular expression.

{% highlight ruby %}
it { should contain_service('httpd').only_with_ensure('running') }
{% endhighlight %}

#### with and without
This can become very verbose when you're testing for multiple parameters, so
you can also chain `.with` and `.without` methods on to the end of your tests
and pass it a hash of parameters.

{% highlight ruby %}
it do
  should contain_service('apache').with(
    'ensure'     => 'running',
    'enable'     => 'true',
    'hasrestart' => 'true',
  )
end
{% endhighlight %}

#### only_with
The chaining also works with the `.only_with` method, by passing a hash of
parameters. These will be the exact set of parameters the catalogue should
contain for that resource or class.

{% highlight ruby %}
it do
  should contain_user('luke').only_with(
    'ensure' => 'present',
    'uid'    => '501',
  )
end
{% endhighlight %}

### have_resource_count
To test for an exact number of resources in the manifest, you can use the
`have_resource_count` matcher.

{% highlight ruby %}
it { should have_resource_count(2) }
{% endhighlight %}

### have_class_count
It is also possible to test the number of classes in a manifest. Use the
`have_class_count` matcher for this.

{% highlight ruby %}
it { should have_class_count(1) }
{% endhighlight %}

### have\_\*\_resource\_count
To test the number of resources of a specific type in the manifest, the
`have_<resource type>_resource_count` matcher is available. This works for
both native and defined types.

If the resource type you're testing for contains `::` in it, replace the `::`
with `__` (two underscores).  For example, to test that your manifest contains
a single `logrotate::rule` resource you would do

{% highlight ruby %}
it { should have_logrotate__rule_resource_count(1) }
{% endhighlight %}

*NOTE*: when testing a class, the catalogue generated will always contain at
least one class, the class under test. The same holds for defined types, the
catalogue generated when testing a defined type will have at least one resource
(the defined type itself).

### Relationship matchers
The following methods will allow you to test the relationships between the
resources in your catalogue, regardless of how the relationship is defined.
This means that it doesn't matter if you prefer to define your relationships
with the metaparameters (`require`, `before`, `notify` and `subscribe`) or the
chaining arrows (`->`, `~>`, `<-` and `<~`), they're all tested the same.

{% highlight ruby %}
it { should contain_file('foo').that_requires('File[bar]') }
it { should contain_file('foo').that_comes_before('File[bar]') }
it { should contain_file('foo').that_notifies('File[bar]') }
it { should contain_file('foo').that_subscribes_to('File[bar]') }
{% endhighlight %}

You can also test the reverse direction of the relationship, so if you have the
following bit of Puppet code

{% highlight puppet %}
notify { 'foo': }
notify { 'bar':
  before => Notify['foo'],
}
{% endhighlight %}

You can test that `Notify[bar]` comes before `Notify[foo]`

{% highlight ruby %}
it { should contain_notify('bar').that_comes_before('Notify[foo]') }
{% endhighlight %}

Or, you can test that `Notify[foo]` requires `Notify[bar]`

{% highlight ruby %}
it { should contain_notify('foo').that_requires('Notify[bar]') }
{% endhighlight %}

## Testing for errors
Sometimes you want to test that a particular situation will cause Puppet to
raise an error, such as paramater validation.  You can accomplish this using
a combination of rspec-puppet and RSpec matchers.

{% highlight ruby %}
describe 'my::type' do
  context 'with foo => true' do
    let(:params) { {:foo => true} }

    it { should compile }
  end

  context 'with foo => bar' do
    let(:params) { {:foo => 'bar'} }

    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /foo must be a boolean/)
    end
  end
end
{% endhighlight %}

## Functions
### run
In order to test that a Puppet function works correctly, you should use the
`run` matcher.

{% highlight ruby %}
it { should run.with_params('foo').and_return('bar') }
{% endhighlight %}

You can also test how your Puppet function fails under certain conditions using
the `and_raise_error`.

You can test the message raised with the exception by passing a string or
regular expression to `and_raise_error`

{% highlight ruby %}
it { should run.with_params().and_raise_error(/incorrect number of arguments) }
{% endhighlight %}

Or, you can test for just the type of exception raised

{% highlight ruby %}
it { should run.with_params().and_raise_error(ArgumentError) }
{% endhighlight %}

If you want to be thorough, you can also test for the exception type and the
message

{% highlight ruby %}
it { should run.with_params().and_raise_error(ArgumentError, /number of arguments/) }
{% endhighlight %}
