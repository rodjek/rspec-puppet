---
layout: base
title: Testing Applications
icon: fa fa-cubes
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
Application management is only available on Puppet >= 4.3.0
</div>
</div>

## Basic Test Structure

{% highlight ruby %}
describe '<application name>' do
  let(:node) { '<host name>' }
  let(:title) { '<application instance title>' }
  let(:params) do
    {
      'nodes' => {
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

<div class="callout-block callout-info">
<div class="icon-holder"><i class="fa fa-info-circle"></i></div>
<div class="content">
Cross-node support is not available at the moment and will return an error.
Ensure that you model your tests to be single-node.
</div>
</div>

## Configuring The Tests

{% include non_host_inputs.md %}

{% include common_inputs.md %}

{% include facts_inputs.md %}

## Testing The Catalogue

{% include catalogue_matchers.md %}
