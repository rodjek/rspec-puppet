module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      define_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = module_path
      Puppet[:code] = define_name + " { \"" + title + "\": " + params.keys.map { |r|
        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"

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
