---
layout: base
title: Testing Applications
icon: fa fa-cubes
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

{% callout info %}
Application management is only available on Puppet >= 4.3.0
{% endcallout %}

## Basic Test Structure

{% highlight ruby %}
describe '<application name>' do
  let(:node) { '<host name>' }
  let(:title) { '<application instance title>' }
  let(:params) do
    {
      :nodes => {
        ref('Node', node) => ref('<capitalised application name>', title),
      }
      # any additional app parameters
    }
  end

  # tests go here
end
{% endhighlight %}

 * The `node` definition is required to be set so that it can be later
   referenced in the `nodes` parameter.
 * Applications act like defined types and require a `title` to be defined.
 * The `nodes` parameter requires the use of node reference mappings to
   resource mappings. The `ref` method creates these references (a normal
   string will not suffice).

{% callout info %}
Cross-node support is not available at the moment and will return an error.
Ensure that you model your tests to be single-node.
{% endcallout %}

## Configuring The Tests

{% include non_host_inputs.md %}

{% include common_inputs.md %}

{% include facts_inputs.md %}

## Testing The Catalogue

{% include catalogue_matchers.md %}
