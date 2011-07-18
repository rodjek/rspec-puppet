module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path

      klass_name = self.class.top_level_description.downcase

      # If we're testing a standalone module (i.e. one that's outside of a
      # puppet tree), the autoloader won't work, so we need to fudge it a bit.
      if File.exists?(File.join(Puppet[:modulepath], 'manifests', 'init.pp'))
        path_to_manifest = File.join([Puppet[:modulepath], 'manifests', klass_name.split('::')[1..-1]].flatten)
        import_str = "import '#{Puppet[:modulepath]}/manifests/init.pp'\nimport '#{path_to_manifest}.pp'\n"
      else
        import_str = ""
      end

      if !self.respond_to?(:params) || params == {}
        Puppet[:code] = import_str + "include #{klass_name}"
      else
        Puppet[:code] = import_str + 'class' + " { " + klass_name + ": " + params.keys.map { |r| "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"
      end

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = self.respond_to?(:facts) ? facts : {}

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        require 'puppet/face'
        Puppet::Face[:catalog, :current].find(node_obj.name, :use_node => node_obj)
      end
    end
  end
end
