module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      vardir = Dir.mktmpdir
      Puppet[:vardir] = vardir
      Puppet[:hiera_config] = self.respond_to?(:hiera_config) ? hiera_config : RSpec.configuration.hiera_config
      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:manifestdir] = self.respond_to?(:manifest_dir) ? manifest_dir : RSpec.configuration.manifest_dir
      Puppet[:manifest] = self.respond_to?(:manifest) ? manifest : RSpec.configuration.manifest
      Puppet[:templatedir] = self.respond_to?(:template_dir) ? template_dir : RSpec.configuration.template_dir
      Puppet[:config] = self.respond_to?(:config) ? config : RSpec.configuration.config
      Puppet[:confdir] = self.respond_to?(:confdir) ? config : RSpec.configuration.confdir

      klass_name = self.class.top_level_description.downcase

      # If we're testing a standalone module (i.e. one that's outside of a
      # puppet tree), the autoloader won't work, so we need to fudge it a bit.
      if File.exists?(File.join(Puppet[:modulepath], 'manifests', 'init.pp'))
        path_to_manifest = File.join([Puppet[:modulepath], 'manifests', klass_name.split('::')[1..-1]].flatten)
        import_str = "import '#{Puppet[:modulepath]}/manifests/init.pp'\nimport '#{path_to_manifest}.pp'\n"
      elsif File.exists?(Puppet[:modulepath])
        import_str = "import '#{Puppet[:manifest]}'\n"
      else
        import_str = ""
      end

      if self.respond_to? :pre_condition
        if pre_condition.kind_of?(Array)
          pre_cond = pre_condition.join("\n")
        else
          pre_cond = pre_condition
        end
      else
        pre_cond = ''
      end

      if !self.respond_to?(:params) || params == {}
        code = import_str + "include #{klass_name}"
      else
        param_str = params.keys.map { |r|
          param_val = escape_special_chars(params[r].inspect)
          "#{r.to_s} => #{param_val}"
        }.join(',')
        code = import_str + 'class' + " { \"" + klass_name + "\": " + param_str + " }"
      end
      code = pre_cond + "\n" + code

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
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
