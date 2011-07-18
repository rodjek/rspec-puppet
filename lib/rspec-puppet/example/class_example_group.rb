module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      klass_name = self.class.top_level_description.downcase
      if params || params == {}
        Puppet[:code] = "include #{klass_name}"
      else
        Puppet[:code] = 'class' + " { " + klass_name + ": " + params.keys.map { |r|        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"
      end

      node = Puppet::Node.new('test_node')

      Puppet::Resource::Catalog.find(node.name, :use_node => node)
      node.merge(facts)
    end
  end
end
