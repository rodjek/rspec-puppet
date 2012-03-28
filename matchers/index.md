---
layout: minimal
---

# Matchers
## Classes, Defined Types and Hosts
### include_class
In order to test that your manifest has successfully included a class, you
should use the `include_class` matcher

{% highlight ruby %}
it { should include_class('my::class') }
{% endhighlight %}

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

Further to this, you can test for the presence or absence of parameters on
these resources by chaining any number of `.with_<parameter>` or 
`.without_<parameter>` methods onto the end of your test.  These methods can
either take an exact value or a regular expression.

{% highlight ruby %}
it { should contain_service('mysql-server').with_ensure('present') }
it { should contain_file('/etc/logrotate.d/apache').with_content(/compress/) }
{% endhighlight %}

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

## Functions
### run
In order to test that a Puppet function works correctly, you should use the
`run` matcher.

{% highlight ruby %}
it { should run.with_params('foo').and_return('bar') }
{% endhighlight %}

## Testing for errors
Sometimes you want to test that a particular situation will cause Puppet to
raise an error, such as paramater validation.  You can accomplish this using
a combination of rspec-puppet and RSpec matchers.

{% highlight ruby %}
describe 'my::type' do
  context 'with foo => true' do
    let(:params) { {:foo => true} }

    it { should contain_file('/tmp/test') }
  end

  context 'with foo => bar' do
    let(:params) { {:foo => 'bar'} }

    it do
      expect {
        should contain_file('/tmp/test')
      }.to raise_error(Puppet::Error, /foo must be a boolean/)
    end
  end
end
{% endhighlight %}
