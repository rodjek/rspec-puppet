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

### module\_path
**Type:** String<br />
**Puppet Version(s):** any

The path to the directory containing the Puppet modules.

## Useful settings
### default\_facts
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** any

A hash of default facts that should be used for all the tests.

### hiera\_config
**Type:** String<br />
**Default:** `/dev/null`<br />
**Puppet Version(s):** any

The path to your `hiera.yaml` file (if used).

### default\_node\_params
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** any

A hash of default node parameters that should be used for all the tests.

### default\_trusted\_facts
**Type:** Hash<br />
**Default:** None<br />
**Puppet Version(s):** any

A hash of default trusted facts that should be used for all the tests
(available in the manifests as `$trusted`).

### setup\_fixtures
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** any

Configures rspec-puppet to automatically create a link from the root of your
module to `spec/fixtures/<module name>` at the beginning of the test run.

### trusted\_server\_facts
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** any

Configures rspec-puppet to use the `$server_facts` hash when compiling the
catalogues.

## Optional overrides
Only set these values if you need to. rspec-puppet is generally pretty good at
determining the values itself, but if you need to override them you can.

### confdir
**Type:** String<br />
**Default:** `/etc/puppet`<br />
**Puppet Version(s):** any

The path to the main Puppet configuration directory.

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#confdir)
for further details.

### config
**Type:** String<br />
**Default:** Puppet's default value<br />
**Puppet Version(s):** any

The path to `puppet.conf`.

See the [Puppet documentation](https://docs.puppet.com/puppet/latest/configuration.html#config)
for further details.

### manifest
**Type:** String<br />
**Default:** Puppet's default value<br />
**Puppet Version(s):** any

Path to test manifest. Typically `spec/fixtures/manifests/site.pp`.

See the [Puppet documentation](https://docs.puppet.com/puppet/latest/configuration.html#manifest)
for further details.

### environmentpath
**Type:** String<br />
**Default:** `/etc/puppetlabs/code/environments`<br />
**Puppet Version(s):** any

The search path for environment directories.

See the [Puppet
documentation](https://docs.puppet.com/puppet/latest/configuration.html#environmentpath)
for further details.

### strict\_variables
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** any

Makes Puppet raise an error when it tries to reference a variable that hasn't
been defined (not including variables that have been explicitly set to
`undef`).

### stringify\_facts
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** any

Makes rspec-puppet coerce all the fact values into strings (matching the
behaviour of older versions of Puppet).

### enable\_pathname\_stubbing
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** any

Configures rspec-puppet to stub out `Pathname#absolute?` with its own
implementation. This should only be enabled if you're running into an issue
running cross-platform tests where you have Ruby code (types, providers,
functions, etc) that use `Pathname#absolute?`.

### derive\_node\_facts\_from\_nodename
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** any

If `true`, rspec-puppet will override the `fdqn`, `hostname`, and `domain`
facts with values that it derives from the node name (specified with
`let(:node)`.

In some circumstances (e.g. where your nodename/certname is not the same as
your FQDN), this behaviour is undesirable and can be disabled by changing this
setting to `false`.

### vendormoduledir
**Type:** String<br />
**Default:** `'/dev/null'` (or `'c:/nul/'` on Windows)
**Puppet Version(s):** any

The path to the directory containing vendored modules. Almost always
unnecessary in a testing environment.

### basemodulepath
**Type:** String<br />
**Default:** `'/dev/null'` (or `'c:/nul/'` on Windows)
**Puppet Version(s):** any

The search path for global modules. Almost always unnecessary in a testing
environment.

### disable_module_hiera
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** any

Enabling this will prevent Puppet from using module-layer Hiera data entirely.
This includes the module being tested as well as any fixture modules.
The end effect is that only Hiera data from the global `:hiera_config` parameter will be used

### fixture_hiera_configs
**Type:** Hash<br />
**Default:** `{}`<br />
**Puppet Version(s):** any

A hash of module names and their respective module-layer Hiera config file paths.
This can be used to override the path to the module-layer hiera.yaml

### use_fixture_spec_hiera
**Type:** Boolean<br />
**Default:** `false`<br />
**Puppet Version(s):** any

Enabling this will prevent Puppet from using the module-layer Hiera config file and instead search the module spec folder for a file named hiera.yaml.

### fallback_to_default_hiera
**Type:** Boolean<br />
**Default:** `true`<br />
**Puppet Version(s):** any

A hash of module names and their respective module-layer Hiera config file paths.
This can be used to override the path to the module-layer hiera.yaml.
