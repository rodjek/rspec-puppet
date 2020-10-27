---
layout: base
title: Coverage Reports
icon: fa fa-map-o
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Report

rspec-puppet can generate a basic resource coverage report at the end of the
test run by the following to your `spec/spec_helper.rb` file.

{% highlight ruby %}
RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
{% endhighlight %}

This checks which Puppet resources have been explicitly checked as part of the
test run and outputs both a coverage percentage and a list of untouched
resources.

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
If you are using <code>parallel_tests</code> to speed up your rspec-puppet and
want to generate coverage reports, you <b>must</b> configure it in an
<code>after(:suite)</code> hook in <code>spec/spec_helper.rb</code> as
documented above and not with any other method (like an <code>at_exit</code>
hook in a spec file).
</div>
</div>

## Setting A Minimum Coverage Level

A desired code coverage percentage can be provided as an argument to
`RSpec::Puppet::Coverage.report!`.

{% highlight ruby %}
RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(95)
  end
end
{% endhighlight %}

If this percentage is not achieved, a test failure will be raised.

## Excluded Resources

Resources declared outside of the module being tested (i.e. resources added by
module dependencies) are automatically excluded from the coverage report.

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
Prior to Puppet 4.6.0, resources created by functions
(<code>create_resources</code>, <code>ensure_packages</code> etc) did not have
the required information in them to determine which manifest they came from and
so can not be excluded from the coverage report.
</div>
</div>

To exclude other resources from the coverage reports, for example to avoid `anchor`s,
use the `add_filter(type, title)` and `add_filter_regex(type, regex)` methods:

{% highlight ruby %}
RSpec.configure do |c|
  c.before(:suite) do
    # Exclude File[/tmp] from all coverage reports
    RSpec::Puppet::Coverage.add_filter('File', '/tmp')
    # Exclude all anchor resources from all coverage reports
    RSpec::Puppet::Coverage.add_filter_regex('Anchor', '.*')
  end
end
{% endhighlight %}

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-exclamation-triangle"></i></div>
<div class="content">
Note that currently filters are global and do not get reset in between examples.
To avoid accidents you should only configure global excludes and only in the
`before(:suite)` hook.
</div>
</div>
