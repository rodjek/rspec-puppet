module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      Puppet[:code] = "include #{self.class.metadata[:example_group][:full_description].downcase}"

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = {}
      facts_val.merge(facts) if self.respond_to? :facts

      node = Puppet::Node.new(nodename)
      facts = Puppet::Node::Facts.new(nodename, facts_val)

      node.merge(facts.values)

      Puppet::Resource::Catalog.find(node.name, :use_node => node)
    end
  end
end
