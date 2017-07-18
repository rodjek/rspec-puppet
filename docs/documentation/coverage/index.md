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

{% callout info %}
Prior to Puppet 4.6.0, resources created by functions (`create_resources`,
`ensure_packages` etc) did not have the required information in them to
determine which manifest they came from and so can not be excluded from the
coverage report
{% endcallout %}
