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
      facts_val = self.respond_to?(:facts) ? facts : {}

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
    end
  end
end
