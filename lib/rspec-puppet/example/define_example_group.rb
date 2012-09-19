module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      define_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:manifestdir] = self.respond_to?(:manifest_dir) ? manifest_dir : RSpec.configuration.manifest_dir
      Puppet[:manifest] = self.respond_to?(:manifest) ? manifest : RSpec.configuration.manifest
      Puppet[:templatedir] = self.respond_to?(:template_dir) ? template_dir : RSpec.configuration.template_dir
      Puppet[:config] = self.respond_to?(:config) ? config : RSpec.configuration.config

      # If we're testing a standalone module (i.e. one that's outside of a
      # puppet tree), the autoloader won't work, so we need to fudge it a bit.
      if File.exists?(File.join(Puppet[:modulepath], 'manifests', 'init.pp'))
        path_to_manifest = File.join([Puppet[:modulepath], 'manifests', define_name.split('::')[1..-1]].flatten)
        import_str = "import '#{Puppet[:modulepath]}/manifests/init.pp'\nimport '#{path_to_manifest}.pp'\n"
      elsif File.exists?(Puppet[:modulepath])
        import_str = "import '#{Puppet[:manifest]}'\n"
      else
        import_str = ""
      end

      if self.respond_to? :params
        param_str = params.keys.map { |r|
          "#{r.to_s} => #{params[r].inspect}"
        }.join(', ')
      else
        param_str = ""
      end

      if self.respond_to? :pre_condition
        pre_cond = pre_condition
      else
        pre_cond = ""
      end

      code = pre_cond + "\n" + import_str + define_name + " { \"" + title + "\": " + param_str + " }"

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = {
        'hostname' => nodename.split('.').first,
        'fqdn' => nodename,
        'domain' => nodename.split('.', 2).last,
      }
      facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)
      exp_res = self.respond_to?(:exported_resources) ? exported_resources : []

      build_catalog(nodename, facts_val, exp_res, code)
    end
  end
end
