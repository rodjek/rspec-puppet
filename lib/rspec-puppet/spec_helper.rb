require 'rspec-puppet'

fixture_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures')

RSpec.configure do |c|
  c.module_path     = File.join(fixture_path, 'modules')
  c.manifest_dir    = File.join(fixture_path, 'manifests')
  c.manifest        = File.join(fixture_path, 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  c.before(:each) do
    # work around https://tickets.puppetlabs.com/browse/PUP-1547
    # ensure that there's at least one provider available by emulating that any
    if Puppet::version < '3.2'
      # ONLY WORKING WITH PUPPET < 3.2 !!
      require 'puppet/provider/confine/exists'
      Puppet::Provider::Confine::Exists.any_instance.stubs(:which => '')
    else
      # ONLY WORKING WITH PUPPET >= 3.2 !!
      require 'puppet/confine/exists'
      Puppet::Confine::Exists.any_instance.stubs(:which => '')
    end
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end
end
