module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def before_each_compile
      @@saved_indirection_state = {}
      indirections = Puppet::Indirector::Indirection.send(:class_variable_get, :@@indirections)
      indirections.each do |indirector|
        @@saved_indirection_state[indirector.name] = {
            :@terminus_class => indirector.instance_variable_get(:@terminus_class),
            :@cache_class    => indirector.instance_variable_get(:@cache_class)
        }
      end
    end

    def after_each_compile
      indirections = Puppet::Indirector::Indirection.send(:class_variable_get, :@@indirections)
      indirections.each do |indirector|
        @@saved_indirection_state.fetch(indirector.name, {}).each do |variable, value|
          indirector.instance_variable_set(variable, value)
        end
      end
      @@saved_indirection_state = nil

      # Clean up storeconfigs
      Puppet::Rails::PuppetTag.accumulators.each do |name,accumulator|
        accumulator.reset
      end if defined?(Puppet::Rails)
      if defined?(ActiveRecord::Base) and ActiveRecord::Base.connected?
        Puppet::Rails.teardown
        ActiveRecord::Base.remove_connection
      end
    end

    def export_resources(exp_res)
      # Puppet 3 scopes require a compiler while Puppet 2 scopes require nothing
      case Puppet.version
      when /^3/
        compiler = Puppet::Parser::Compiler.new(Puppet::Node.new("mock_node"))
        scope = Puppet::Parser::Scope.new(compiler)
      when /^2/
        scope = Puppet::Parser::Scope.new
      else
        raise Puppet::Error, "Puppet version #{Puppet.version} is not recognised by rspec-puppet"
      end
      catalog = Puppet::Resource::Catalog.new("mock_node")
      (exp_res||{}).each do |type, resource|
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
      request = Puppet::Indirector::Request.new(:active_record, :save, nil, catalog)
      Puppet::Resource::Catalog::ActiveRecord.new.save(request)
    end

    def build_catalog_without_cache(nodename, facts_val, exp_res, code)
      before_each_compile

      if ! (exp_res.is_a? Array and exp_res.empty?)
        if can_use_scratch_database?
          setup_scratch_database
          export_resources(exp_res)
        else
          raise Puppet::Error, "Unable to use scratch database for exported resources."
        end
      end

      Puppet[:code] = code

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        Puppet::Resource::Catalog.indirection.find(node_obj.name, :use_node => node_obj)
      end
    ensure
      after_each_compile
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
