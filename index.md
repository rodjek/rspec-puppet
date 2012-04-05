---
layout: minimal
---

## Installing

{% highlight console %}
$ gem install rspec-puppet
{% endhighlight %}

If you don't have Puppet installed as a system package, you'll also need
to

{% highlight console %}
$ gem install puppet
{% endhighlight %}

## Getting Started

Go to your module, and run this handy script to prepare it for testing

{% highlight console %}
$ cd path/to/your/module
$ rspec-puppet-init
{% endhighlight %}

If this fails or you wish to prepare your module manually, follow these
[instructions](/setup/).

Now, proceed to the [tutorial](/tutorial/)!
