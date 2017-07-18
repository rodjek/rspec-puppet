---
layout: base
title: Testing Defined Types
icon: fa fa-copy
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Test Structure

Tests for defined types should be placed in files under `spec/defines/`. For
example the tests for `apache::vhost` should be in
`spec/defines/apache_vhost_spec.rb`.

{% highlight ruby %}
require 'spec_helper'

describe '<defined type name >' do
  let(:title) { '<namevar/title>' }

  # let(:params) { ... }

  # it { is_expected.to ... }
end
{% endhighlight %}

## Configuring The Tests

### Specifying the title

As when using a defined type, when testing a defined type it must have a title.
This can be specified using `let(:title)`.

{% highlight ruby %}
let(:title ) { 'something' }
{% endhighlight %}

{% include non_host_inputs.md %}

{% include common_inputs.md %}

{% include facts_inputs.md %}

## Testing The Catalogue

{% include catalogue_matchers.md %}
