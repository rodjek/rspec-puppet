### Specifying facts

By default, the test environment contains only the `hostname`, `domain`, and
`fqdn` facts (determined by the FQDN of the test node). Additional facts can be
specified as a hash of values using `let(:facts)`.

{% highlight ruby %}
let(:facts) { {:operatingsystem => 'Debian', :ipaddress => '192.168.0.1'} }
{% endhighlight %}

Facts may be expressed as a value (shown in the previous example) or
a structure. Fact keys may be expressed as symbols or strings, and will be
converted to a lower case string to align with the Facter standard.

{% highlight ruby %}
let(:facts) do
  {
    :os => {
      :family  => 'RedHat',
      :release => {
        :major => '7',
        :minor => '1',
        :full  => '7.1.1503',
      }
    }
  }
end
{% endhighlight %}

These facts will be merged into the default facts (if set), with these values
taking precedence over the default fact values in the event of a conflict.

### Specifying trusted facts

When testing with Puppet >= 4.3, the trusted facts hash will have the standard
trusted facts (`certname`, `domain`, and `hostname`) populated based on the
node name.

By default, the test environment contains no custom trusted facts (usually
obtained from certificate extensions) and found in the `extensions` key. If the
manifest being tested depends on the values from specific custom certificate
extensions, they can be specified as a hash using `let(:trusted_facts)`.

{% highlight ruby %}
let(:trusted_facts) { {'pp_uuid' => '012345670-ABCD', 'some' => 'value'} }
{% endhighlight %}

These trusted facts will be merged into the default trusted facts (if set),
with these values taking precedence over the default trusted facts in the event
of a conflict.
