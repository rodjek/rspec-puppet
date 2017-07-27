### Specifying the environment name

If the manifest being tested expects to evaluate the environment name, it can
be specified using `let(:environment)`.

{% highlight ruby %}
let(:environment) { 'production' }
{% endhighlight %}

### Specifying node parameters

Node parameters (or top-scope variables) such as would be provided by an ENC
can be specified as a hash of values using `let(:node_params)`.

{% highlight ruby %}
let(:node_params) { {'hostgroup' => 'web', 'rack' => 'KK04' } }
{% endhighlight %}

These node parameters will be merged into the default node parameters (if set),
with these values taking precedence over the default node parameters in the
event of a conflict.

### Specifying code to include before

If the manifest being tested relies on some existing state (another class being
included, variables to be set, etc), this can be specified using
`let(:pre_condition)`.

{% highlight ruby %}
let(:pre_condition) { 'include some::other_class' }
{% endhighlight %}

The value may be a string or an array of strings that will be concatenated, and
then be evaluated before the manifest being tested.

### Specifying code to include after

If the manifest being tested depends on being evaluated before another
manifest, this can be specified using `let(:post_condition)`.

{% highlight ruby %}
let(:post_condition) { 'include some::other_class::after' }
{% endhighlight %}

The value may be a string or an array of strings that will be concatenated, and
then be evaluated after the manifest being tested.
