---
layout: base
title: Getting Started
icon: fa fa-toggle-on
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---
## Installation

### Installing rspec-puppet

If you are using [Bundler](https://bundler.io) to manage the gems in your
module or control repository (highly recommended), you should add rspec-puppet
to your `Gemfile` and then run `bundle install`.

{% highlight ruby %}
gem 'rspec-puppet', '~> 2.0'
{% endhighlight %}

Alternatively, you can install rspec-puppet using `gem`.

{% highlight console %}
$ gem install rspec-puppet
{% endhighlight %}

### Installing Puppet

rspec-puppet needs to have Puppet installed on the host in order to operate,
but does not have it specified in the gem as dependency as Puppet can be
installed as a native package or gem.

If you do not have Puppet installed, you'll need to do so now. If you are using
[Bundler](https://bundler.io) to manage the gems in your module or control
repository, you should add Puppet to your `Gemfile` and then run `bundle
install`.

{% highlight ruby %}
gem 'puppet', ENV.fetch('PUPPET_GEM_VERSION', '>= 0')
{% endhighlight %}

The above snippet will allow you to specify a Puppet version to use in the
`PUPPET_GEM_VERSION` environment variable. This is a common pattern that you
will find in many open source modules that support multiple Puppet versions.

## Setup

### Automatic setup

rspec-puppet ships with a small script that will automate the setup process for
you by creating the various files and directories that rspec and rspec-puppet
require.

{% highlight console %}
$ cd path/to/your/module
$ touch metadata.json
$ rspec-puppet-init
{% endhighlight %}

### Manual setup on Unix-based hosts

Create a `spec` directory inside your module

{% highlight console %}
$ cd path/to/your/module
$ mkdir spec
{% endhighlight %}

Puppet expects to be able to read a default manifest file (usually
`manifests/site.pp`), so a blank one needs to be created.

{% highlight console %}
$ mkdir -p spec/fixtures/{manifests,modules}
$ touch spec/fixtures/manifests/site.pp
{% endhighlight %}

RSpec needs to be configured to use rspec-puppet, which is done in the
`spec/spec_helper.rb` file which should be created now with the following
content.

{% highlight ruby %}
require 'rspec-puppet'

RSpec.configure do |c|
  c.environmentpath = __dir__
  c.module_path = File.join(__dir__, 'fixtures', 'modules')
end
{% endhighlight %}

Optionally, if you are using [Rake](https://ruby.github.io/rake/) to automate
tasks in your module, you can add a `spec` task to your `Rakefile`.

{% highlight ruby %}
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end
{% endhighlight %}

### Manual setup on Windows hosts

**Coming soon!**
