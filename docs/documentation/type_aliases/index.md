---
layout: base
title: Testing Type Aliases
icon: fa fa-exchange
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Test Structure

Tests for data type aliases should be placed under `spec/type_aliases`. For
example, the tests for the `MyModule::Shape` type alias would be placed in
`spec/type_aliases/mymodule_shape_spec.rb`.

{% highlight ruby %}
require 'spec_helper'

describe 'MyModule::Shape' do
  # tests go here
end
{% endhighlight %}

## Testing The Allowed Value(s)

The `allow_value` matcher is used to test how the type alias behaves when given
a particular value.

{% highlight ruby %}
it { is_expected.to allow_value('square') }
{% endhighlight %}

Multiple values can be provided in a single test using the `allow_values`
matcher

{% highlight ruby %}
it { is_expected.to allow_values('circle', 'triangle') }
{% endhighlight %}

## Testing Disallowed Values

You can negate the `allow_value` matcher to test expected failure cases.

{% highlight ruby %}
it { is_expected.not_to allow_values('line', 'point') }
{% endhighlight %}
