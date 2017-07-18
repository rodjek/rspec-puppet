---
layout: base
title: Testing Hosts
icon: fa fa-server
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

## Basic Test Structure

Testing hosts is much the same as testing classes or defined types, you just
need to create your spec file under `spec/hosts/`.

{% highlight ruby %}
require 'spec_helper'

describe '<host name>' do
  # your tests go here
end
{% endhighlight %}

This will look for a node definition in your `site.pp` for the named host,
compile the catalogue for the host and then run your tests over that catalogue.

## Configuring The Tests

{% include common_inputs.md %}

{% include facts_inputs.md %}

## Testing The Catalogue

{% include catalogue_matchers.md %}
