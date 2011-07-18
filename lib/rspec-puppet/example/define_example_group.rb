module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      define_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = module_path

      # If we're testing a standalone module (i.e. one that's outside of a
      # puppet tree), the autoloader won't work, so we need to fudge it a bit.
      if File.exists?(File.join(module_path, 'manifests', 'init.pp'))
        path_to_manifest = File.join([module_path, 'manifests', define_name.split('::')[1..-1]].flatten)
        import_str = "import '#{module_path}/manifests/init.pp'\nimport '#{path_to_manifest}.pp'\n"
      else
        import_str = ""
      end

      if self.respond_to? :params
        param_str = params.keys.map { |r|
          "#{r.to_s} => \"#{params[r].to_s}\""
        }.join(', ')
      else
        param_str = ""
      end

      Puppet[:code] = import_str + define_name + " { \"" + title + "\": " + param_str + " }"

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = self.respond_to?(:facts) ? facts : {}

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        require 'puppet/face'
        Puppet::Face[:catalog, :current].find(node_obj.name, :use_node => node)
      end
    end
  end
end
