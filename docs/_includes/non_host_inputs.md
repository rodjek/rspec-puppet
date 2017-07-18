### Specifying parameters

If the object being tested takes parameters, these can be specified as a hash
of values using `let(:params)`.

{% highlight ruby %}
let(:params) { {:ensure => 'present', :enable => true} }
{% endhighlight %}

When passing `undef` as a parameter value, it should be passed as the symbol
`:undef`.

{% highlight ruby %}
let(:params) { {:user => :undef} }
{% endhighlight %}

When passing a reference to a resource (e.g. `Package['apache2']`), it should
be passed as a call to the `ref` helper (`ref(<resource type>, <resource
title>)`)

{% highlight ruby %}
let(:params) { {:require => ref('Package', 'apache2')} }
{% endhighlight %}

### Specifying the FQDN of the test node

If the object being tested depends upon the node having a certain name, it
can be specified using `let(:node)`.

{% highlight ruby %}
let(:node) { 'testhost.example.com' }
{% endhighlight %}
