module RSpec::Puppet
  module Support
    def build_catalog(nodename, facts_val, additional_resources)
      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        catalogue = Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        require 'puppet/face'
        catalogue = Puppet::Face[:catalog, :current].find(node_obj.name, :use_node => node_obj)
      end

      additional_resources = [additional_resources] if additional_resources.is_a? Hash
      additional_resources.each do |resource|
        catalogue.add_resource Puppet::Resource.new(resource[:type], resource[:title], {:virtual => true, :parameters => resource[:parameters]})
      end

      p catalogue.resource('File[foo]').virtual?
      catalogue.compile
    end
  end
end
