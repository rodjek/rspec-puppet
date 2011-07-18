module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      Puppet[:code] = self.class.metadata[:example_group][:full_description].downcase + " { \"" + title + "\": " + params.keys.map { |r|
        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = self.respond_to?(:facts) ? facts : {}

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
    end
  end
end
