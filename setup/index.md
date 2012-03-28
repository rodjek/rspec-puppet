---
layout: minimal
title: setup
---

# Setup
## Automatic setup

rspec-puppet ships with a small script that will automate the setup process for
you by creating the various files and directories that rspec and rspec-puppet
requires in order to function correctly.

{% highlight console %}
$ cd path/to/your/module
$ rspec-puppet-init
{% endhighlight %}

## Manual setup

First, create the directories that will contain your spec files
{% highlight console %}
$ cd path/to/your/module
$ mkdir -p spec/{classes,defines,hosts,functions}
{% endhighlight %}

Puppet always expects to be able to read a site.pp file, so we'll create
a blank one for it to read when running the tests
{% highlight console %}
$ mkdir -p spec/fixtures/manifests
$ touch spec/fixtures/manifests/site.pp
{% endhighlight %}

In order for Puppet's manifest autoloader to work correctly, it expects to find
your manifests under `<modulepath>/<your module name>/manifests/`.  If we just
set the modulepath to the root of your module, it will be missing `<your module
name>` from the path, so we work around this by creating a directory under
`spec/fixtures/modules` and symlinking your module contents into it
{% highlight console %}
$ mkdir spec/fixtures/modules/<your module name>
$ cd spec/fixtures/modules/<your module name>
$ for i in files lib manifests templates; do ln -s ../../../../$i $i; done
$ cd ../../../../
{% endhighlight %}

Now, you need to configure rspec-puppet to use the fixtures we just set up.
Create `spec/spec_helper.rb` with the following contents
{% highlight ruby %}
require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
{% endhighlight %}

All that's left is to create a Rakefile with a task to run the tests
{% highlight ruby %}
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end
{% endhighlight %}
