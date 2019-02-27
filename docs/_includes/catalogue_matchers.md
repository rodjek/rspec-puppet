### Test that the catalogue compiles

This is the most basic test that can be done on a manifest. It will test that
the manifest can be compiled into a catalogue, and that the catalogue has no
dependency cycles between resources.

{% highlight ruby %}
it { is_expected.to compile }
{% endhighlight %}

This matcher has an optional method that can be chained onto it in order to
have rspec-puppet test that all relationships in the catalogue (as defined with
`require`, `notify`, `subscribe`, `before`, or the chaining arrows) resolve to
resources in the catalogue.

{% highlight ruby %}
it { is_expected.to compile.with_all_deps }
{% endhighlight %}

### Test for errors

When testing for an expected error (e.g. testing the behaviour of input
validation), the `and_raise_error` method should be chained onto the `compile`
matcher.

{% highlight ruby %}
describe 'my::type' do
  context 'with ensure => present' do
    let(:params) { {'ensure' => 'present'} }

    it { is_expected.to compile }
  end

  context 'with ensure => whoopsiedoo' do
    let(:params) { {'ensure' => 'whoopsiedoo'} }

    it { is_expected.to compile.and_raise_error(/the expected error message/) }
  end
end
{% endhighlight %}

### Test a resource

The presence of a resource in the catalogue can be tested using the generic
`contain_<resource type>` matcher.

{% highlight ruby %}
it { is_expected.to contain_service('apache2') }
{% endhighlight %}

If the `<resource type>` includes `::` (e.g. the `apache::vhost` defined type),
you must replace the `::` with `__` (two underscores) in the matcher name.

{% highlight ruby %}
it { is_expected.to contain_apache__vhost('www.mysite.com') }
{% endhighlight %}

This can also be used to test if a class has been included in the catalogue.

{% highlight ruby %}
it { is_expected.to contain_class('apache::vhosts') }
{% endhighlight %}

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
rspec-puppet does not do the class name parsing and lookup that the Puppet
parser would do for you. The matcher only accepts fully qualified class names
without any leading colons. This means that class <code>foo::bar</code> will only be
matched by <code>foo::bar</code>, not by <code>::foo::bar</code> or <code>bar</code> alone.
</div>
</div>

### Test resource parameters

The values of a resource's parameters can be tested by chaining
`with_<parameter name>(<value>)` methods onto the `contain_<resource type>`
matcher.

{% highlight ruby %}
it { is_expected.to contain_apache__vhost('www.mysite.com').with_ensure('present') }
{% endhighlight %}

While you can chain multiple `with_<parameter name>` methods together, it may
be cleaner for a large number of parameters to instead to chain the `with` method
and pass a hash of expected parameters and values instead.

{% highlight ruby %}
it { is_expected.to contain_service('apache').with('ensure' => 'present', 'enable' => true) }
# is equivalent to
it { is_expected.to contain_service('apache').with_ensure('present').with_enable(true) }
{% endhighlight %}

Testing parameters using `with_<parameter name>` or `with` will not take into
account any other parameters that might be set on the resource. In order to
test that **only** the specificied parameters have been set on a resource, the
`only_with_<parameter name>` method can be chained onto the
`contain_<resource type>` matcher.

{% highlight ruby %}
# If any parameters have been set on Package[httpd] other than ensure, this test will fail.
it { is_expected.to contain_package('httpd').only_with_ensure('latest') }
{% endhighlight %}

Similarly to `with_<parameter name>`, there exists a way to specify multiple
parameters at once, by chaining `only_with` onto the `contain_<resource type>`
matcher and passing it a hash of expected parameters and values.

{% highlight ruby %}
it { is_expected.to contain_service('apache').only_with('ensure' => 'running', 'enable' => true) }
{% endhighlight %}

Lastly, there are situations where it is necessary to test that certain
parameters **have not** been set on a resource. This can be done by chaining
`without_<parameter name>` methods onto the `contain_<resource type>` matcher.

{% highlight ruby %}
it { is_expected.to contain_file('/tmp/testfile').without_mode }
{% endhighlight %}

As with the other parameter methods, there is a way to specify multiple
undefined parameters at once by chaining the `without` method to the
`contain_<resource type>` matcher and passing it an array of parameter names.

{% highlight ruby %}
it { is_expected.to contain_service('apache').without(['restart', 'status']) }
{% endhighlight %}

### Test resource parameter values for uniqueness

Use the `have_unique_values_for_all` matcher to test a specific resource parameter
for uniqueness of values across the entire catalogue:

{% highlight ruby %}
it { is_expected.to have_unique_values_for_all('user', 'uid')
{% endhighlight %}

### Testing relationships between resources
The relationships between resources can be tested using the following methods,
regardless of how the relationship has been defined. This mean that it doesn't
matter if it was defined using the relationship metaparameters (`require`,
`before`, `notify`, `subscribe`) or the chaining arrows (`->`, `<-`, `~>`,
`<~`).

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
The values passed to these methods must be in the format used in the Puppet
catalogue (which is slightly different to the way they're written in a Puppet
manifest).
<ul>
<li>The resource titles must be unquoted (<code>Package[apache]</code> instead of <code>Package['apache']</code>)</li>
<li>One title per resource (<code>[Package[apache], Package[htpasswd]]</code> instead of <code>Package[apache, htpasswd]</code>)</li>
<li>If referencing a class, it must be fully qualified and should not have a leading <code>::</code> (<code>Class[apache::service]</code> instead of <code>Class[::apache::service]</code>)</li>
</ul>
</div>
</div>

{% highlight ruby %}
it { is_expected.to contain_file('a').that_requires('File[b]') }
it { is_expected.to contain_file('a').that_comes_before('File[b]') }
it { is_expected.to contain_file('a').that_notifies('File[b]') }
it { is_expected.to contain_file('a').that_subscribes_to('File[b]') }
{% endhighlight %}

An array can be passed if the resource has the same type of relationship to
multiple resources.

{% highlight ruby %}
it { is_expected.to contain_file('a').that_requires(['File[b]', 'File[c]']) }
it { is_expected.to contain_file('a').that_comes_before(['File[b]', 'File[c]']) }
it { is_expected.to contain_file('a').that_notifies(['File[b]', 'File[c]']) }
it { is_expected.to contain_file('a').that_subscribes_to(['File[b]', 'File[c]']) }
{% endhighlight %}

The relationships can be tested in either direction, so given the following
manifest:

{% highlight puppet %}
notify { 'a': }
notify { 'b':
  before => Notify['a'],
}
{% endhighlight %}

It can be tested that `Notify[b]` comes before `Notify[a]`
{% highlight ruby %}
it { is_expected.to contain_notify('b').that_comes_before('Notify[a]') }
{% endhighlight %}

Or that `Notify[a]` requires `Notify[b]`
{% highlight ruby %}
it { is_expected.to contain_notify('a').that_requires('Notify[b]') }
{% endhighlight %}

### Testing the total number of resources

The total number of resources in the catalogue can be tested with the
`have_resource_count` matcher.

{% highlight ruby %}
it { is_expected.to have_resource_count(2) }
{% endhighlight %}

### Testing the total number of classes

The total number of classes in the catalogue can be tested with the
`have_class_count` matcher.

{% highlight ruby %}
it { is_expected.to have_class_count(4) }
{% endhighlight %}

### Testing the number of resources of a specific type

The number of resources of a specific type can be tested using the generic
`have_<resource type>_resource_count` matcher.

{% highlight ruby %}
it { is_expected.to have_exec_resource_count(1) }
{% endhighlight %}

As with the generic `contain_<resource type>` matcher, this matcher can also be
used for defined types that contain `::` in their name by replacing the `::`
with `__` (two underscores).

{% highlight ruby %}
it { is_expected.to have_apache__vhost_resource_count(3) }
{% endhighlight %}
