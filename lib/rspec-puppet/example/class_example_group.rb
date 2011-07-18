module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      Puppet[:code] = "include #{self.class.metadata[:example_group][:full_description].downcase}"

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
