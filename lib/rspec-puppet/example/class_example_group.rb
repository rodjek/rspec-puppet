module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path

      klass_name = self.class.top_level_description.downcase
      if !self.respond_to?(:params) || params == {}
        Puppet[:code] = "include #{klass_name}"
      else
        Puppet[:code] = 'class' + " { " + klass_name + ": " + params.keys.map { |r| "#{r.to_s} => '#{params[r].to_s}'"
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
