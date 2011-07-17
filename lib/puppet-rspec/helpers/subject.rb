module PuppetRSpec
  module Helpers
    def catalogue_for(name, params, module_path)
      Puppet[:modulepath] = module_path
      Puppet[:code] = name + " { " + name + ": " + params.keys.map { |r|
        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"

      unless facts = Puppet::Node::Facts.find(Puppet[:certname])
        raise "Could not find facts for #{Puppet[:certname]}"
      end

      unless node = Puppet::Node.find(Puppet[:certname])
       raise "Could not find node #{Puppet[:certname]}"
      end

      node.merge(facts.values)

      Puppet::Resource::Catalog.find(node.name, :use_node => node)
    end
  end
end
