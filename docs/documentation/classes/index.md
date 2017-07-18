---
layout: base
title: Testing Classes
icon: fa fa-book
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Test Structure

Tests for classes should be placed in files under `spec/classes/`. For
example the tests for `apache::install` should be in
`spec/classes/apache_install_spec.rb`.

{% highlight ruby %}
require 'spec_helper'

describe '<class name>' do
  # let(:params) { ... }

  # it { is_expected.to ... }
end
{% endhighlight %}

## Configuring The Tests

{% include non_host_inputs.md %}

{% include common_inputs.md %}

{% include facts_inputs.md %}

## Testing The Catalogue

{% include catalogue_matchers.md %}
