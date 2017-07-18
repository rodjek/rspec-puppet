---
layout: base
title: Testing Types
icon: fa fa-puzzle-piece
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Test Structure

Tests for types should be placed in files under `spec/types`. For example, the
tests for the `sudoers_entry` type should be in
`spec/types/sudoers_entry_spec.rb`.

{% highlight ruby %}
require 'spec_helper'

describe '<type name>' do
  # tests go here
end
{% endhighlight %}

## Configuring The Tests

{% include non_host_inputs.md %}

{% include facts_inputs.md %}

## Testing The Type

All type testing is currently done with the `be_valid_type` matcher.

### Testing Provider Selection

The automatic provider selection can be tested by chaining the `with_provider`
method on to the `be_valid_type` matcher.

{% highlight ruby %}
it { is_expected.to be_valid_type.with_provider('foo') }
{% endhighlight %}

### Testing Properties

Property names can be tested by chaining the `with_properties` method on to the
`be_valid_type` matcher.

{% highlight ruby %}
it { is_expected.to be_valid_type.with_properties('ensure') }
{% endhighlight %}

### Testing Parameters

Parameter names can be tested by chaining the `with_parameters` method on to
the `be_valid_type` matcher.

{% highlight ruby %}
it { is_expected.to be_valid_type.with_parameters('command', 'unless') }
{% endhighlight %}

### Testing provider features

Provider features can be tested by chaining the `with_features` method on to
the `be_valid_type` matcher.

{% highlight ruby %}
it { is_expected.to be_valid_type.with_features('refreshable') }
{% endhighlight %}
