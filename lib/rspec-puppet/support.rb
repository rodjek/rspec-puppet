module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def build_catalog_without_cache(nodename, facts_val, exp_res, code)

      Puppet[:code] = code

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      exp_res = [exp_res] if exp_res.is_a? Hash

      if exp_res and ! exp_res.empty?
        if can_use_scratch_database?
          setup_scratch_database
          scope = Puppet::Parser::Scope.new
          catalog = Puppet::Resource::Catalog.new("mock_node")
          exp_res.each do |types|
            types.each do |type, resource|
              resource.each do |title, params|
                parser_resource = Puppet::Parser::Resource.new( type, title, {
                  :virtual  => true,
                  :exported => true,
                  :scope    => scope,
                })
                params.each { |attribute, value| parser_resource[attribute] = value } if params
                res = parser_resource.to_resource
                catalog.add_resource res
              end
            end
          end
          request = Puppet::Indirector::Request.new(:active_record, :save, catalog)
          Puppet::Resource::Catalog::ActiveRecord.new.save(request)
        else
          raise Puppet::Error, "Cannot use scratch database for exported resources."
        end
      end

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
