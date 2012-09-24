module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def build_catalog_without_cache(nodename, facts_val, exp_res, code)
      tmpdir = Dir.mktmpdir('rspec-puppet-sqlite')

      if can_use_scratch_database?
        setup_scratch_database(tmpdir)
        export_resources(exp_res)
      else
        raise Puppet::Error, "Unable to use scratch database for exported resources."
      end

      Puppet[:code] = code

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        catalog = Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        catalog = Puppet::Resource::Catalog.indirection.find(node_obj.name, :use_node => node_obj)
      end
      Puppet::Rails::PuppetTag.accumulators.each do |name,accumulator|
        accumulator.reset
      end
      Puppet::Rails.teardown if defined?(ActiveRecord::Base)
      PuppetlabsSpec::Files.cleanup
      catalog
    ensure
      FileUtils.remove_entry_secure tmpdir
    end

    def export_resources(exp_res)
      if exp_res and ! exp_res.empty?
        scope = Puppet::Parser::Scope.new
        catalog = Puppet::Resource::Catalog.new("mock_node")
        exp_res.each do |type, resource|
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
        request = Puppet::Indirector::Request.new(:active_record, :save, catalog)
        Puppet::Resource::Catalog::ActiveRecord.new.save(request)
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
