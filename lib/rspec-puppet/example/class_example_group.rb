module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      unless facts = Puppet::Node::Facts.find(Puppet[:certname])
        raise "Could not find facts for #{Puppet[:certname]}"
      end

      unless node = Puppet::Node.find(Puppet[:certname])
        raise "Could not find node #{Puppet[:certname]}"
      klass_name = self.class.top_level_description.downcase
      if params || params == {}
        Puppet[:code] = "include #{klass_name}"
      else
        Puppet[:code] = 'class' + " { " + klass_name + ": " + params.keys.map { |r|        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"
      end

      node.merge(facts.values)

      Puppet::Resource::Catalog.find(node.name, :use_node => node)
    end
  end
end
