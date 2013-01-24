module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def build_catalog_without_cache(nodename, facts_val, code)
      if Integer(Puppet.version.split('.').first) >= 3
        Puppet.initialize_settings
      end

      Puppet[:code] = code

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        Puppet::Resource::Catalog.indirection.find(node_obj.name, :use_node => node_obj)
      end
    end

    public
    def build_catalog *args
      @@cache[args] ||= self.build_catalog_without_cache(*args)
    end

    def munge_facts(facts)
      output = {}
      facts.keys.each { |key| output[key.to_s] = facts[key] }
      output
    end
  end
end
