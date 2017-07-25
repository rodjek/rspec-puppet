---
layout: base
title: Configuration
icon: fa fa-wrench
breadcrumbs:
    -
        name: Documentation
        path: /documentation/
---
rspec-puppet can be configured by modifying the `RSpec.configure` block in your
`spec/spec_helper.rb` file. If you followed the [setup
instructions](/documentation/setup/) you'll already have an `RSpec.configure`
block that you can modify.

{% highlight ruby %}
RSpec.configure do |c|
  c.<config option> = <value>
end
{% endhighlight %}

## Required settings
### manifest\_dir
**Type:** String<br />
**Puppet Version(s):** 2.x, 3.x

The path to the directory containing your basic manifests like `site.pp`.

### module\_path
**Type:** String<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

The path to the directory containing the Puppet modules.

## Useful settings
### default\_facts
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

A hash of default facts that should be used for all the tests.

### hiera\_config
**Type:** String<br />
**Default:** `/dev/null`<br />
**Puppet Version(s):** 3.x, 4.x, 5.x

The path to your `hiera.yaml` file (if used).

### default\_node\_params
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** 4.x, 5.x

A hash of default node parameters that should be used for all the tests.

### default\_trusted\_facts
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** 4.x, 5.x

A hash of default trusted facts that should be used for all the tests
(available in the manifests as `$trusted`). In order to use this,
`trusted_node_data` must also be set to `true`.

### trusted\_node\_data
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** ~> 3.4, 4.x, 5.x

Makes rspec-puppet use the `$trusted` hash when testing catalogues.

### setup\_fixtures
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

Configures rspec-puppet to automatically create a link from the root of your
module to `spec/fixtures/<module name>` at the beginning of the test run.

## Optional overrides
Only set these values if you need to. rspec-puppet is generally pretty good at
determining the values itself, but if you need to override them you can.

### confdir
**Type:** String<br />
**Default:** `/etc/puppet`<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

The path to the main Puppet configuration directory.

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#confdir)
for further details.

### config
**Type:** String<br />
**Default:** Puppet's default value<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

The path to `puppet.conf`.

See the [Puppet documentation](https://docs.puppet.com/puppet/latest/configuration.html#config)
for further details.

### manifest
**Type:** String<br />
**Default:** Puppet's default value<br />
**Puppet Version(s):** 2.x, 3.x

The entry-point manifest for Puppet, usually `<manifest_dir>/site.pp`.

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#manifest)
for further details.

### template\_dir
**Type**: String<br />
**Default:** None<br />
**Puppet Version(s):** 2.x, 3.x

The path to the directory that Puppet should search for templates stored
outside of modules.

See the [Puppet
documentation](https://docs.puppet.com/puppet/3.8/deprecated_settings.html#templatedir)
for further details.

### environmentpath
**Type:** String<br />
**Default:** `/etc/puppetlabs/code/environments`<br />
**Puppet Version(s):** 4.x, 5.x

The search path for environment directories.

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#environmentpath)
for further details.

### parser
**Type:** String<br />
**Default:** `current`<br />
**Puppet Version(s):** ~> 3.2

This switches between the 3.x (`current`) and 4.x (`future`) parsers.

See the [Puppet
documentation](https://docs.puppet.com/puppet/3.8/deprecated_settings.html#parser)
for further details.

### ordering
**Type:** String<br />
**Default:** `title-hash`<br />
**Puppet Version(s):** ~> 3.3, 4.x, 5.x

How unrelated resources should be ordered when applying a catalogue.
 * `manifest` - Use the order in which the resources are declared in the
   manifest.
 * `title-hash` - Order the resources randomly, but in a consistent manner
   across runs (the order will only change if the code changes).
 * `random` - Order the resources randomly (ideal for finding resources that
   do not have explicit dependencies).

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#ordering)
for further details.

### strict\_variables
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** ~> 3.5, 4.x, 5.x

Makes Puppet raise an error when it tries to reference a variable that hasn't
been defined (not including variables that have been explicitly set to
`undef`).

### stringify\_facts
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** ~> 3.3, 4.x, 5.x

Makes rspec-puppet coerce all the fact values into strings (matching the
behaviour of older versions of Puppet).

### enable\_pathname\_stubbing
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** 2.x, 3.x, 4.x, 5.x

Configures rspec-puppet to stub out `Pathname#absolute?` with its own
implementation. This should only be enabled if you're running into an issue
running cross-platform tests where you have Ruby code (types, providers,
functions, etc) that use `Pathname#absolute?`.
