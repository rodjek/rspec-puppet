module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::Matchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      define_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path

      # If we're testing a standalone module (i.e. one that's outside of a
      # puppet tree), the autoloader won't work, so we need to fudge it a bit.
      if File.exists?(File.join(Puppet[:modulepath], 'manifests', 'init.pp'))
        path_to_manifest = File.join([Puppet[:modulepath], 'manifests', define_name.split('::')[1..-1]].flatten)
        import_str = "import '#{Puppet[:modulepath]}/manifests/init.pp'\nimport '#{path_to_manifest}.pp'\n"
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

      Puppet[:code] = pre_cond + "\n" + import_str + define_name + " { \"" + title + "\": " + param_str + " }"

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = {
        'hostname' => nodename.split('.').first,
        'fqdn' => nodename,
      }
      facts_val.merge!(facts) if self.respond_to?(:facts)

      build_catalog(nodename, facts_val)
    end
  end
end
