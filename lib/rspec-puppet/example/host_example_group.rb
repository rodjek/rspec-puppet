module RSpec::Puppet
  module HostExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      vardir = Dir.mktmpdir
      Puppet[:vardir] = vardir
      Puppet[:hiera_config] = File.join(vardir, "hiera.yaml") if Puppet[:hiera_config] == File.expand_path("/dev/null")
      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:manifestdir] = self.respond_to?(:manifest_dir) ? manifest_dir : RSpec.configuration.manifest_dir
      Puppet[:manifest] = self.respond_to?(:manifest) ? manifest : RSpec.configuration.manifest
      Puppet[:templatedir] = self.respond_to?(:template_dir) ? template_dir : RSpec.configuration.template_dir
      Puppet[:config] = self.respond_to?(:config) ? config : RSpec.configuration.config
      code = ""

      nodename = self.class.top_level_description.downcase

      facts_val = {
        'hostname' => nodename.split('.').first,
        'fqdn' => nodename,
        'domain' => nodename.split('.').last,
      }
      facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)

      catalogue = build_catalog(nodename, facts_val, code)
      FileUtils.rm_rf(vardir) if File.directory?(vardir)
      catalogue
    end
  end
end
