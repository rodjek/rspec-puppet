class Puppet::Parser::Compiler
  def compile
    set_node_parameters
    create_settings_scope

    evaluate_main

    evaluate_ast_node

    mock_resources.each do |r|
      add_resource(topscope, r)
    end

    evaluate_node_classes

    evaluate_generators

    finish

    fail_on_unevaluated

    @catalog
  end
end

class Puppet::Parser::Collector
  def collect_exported
    if @equery =~ /param_values.value = '(.*?)' and param_names.name = '(.*?)'/
      param_value = $1
      param_name = $2.to_sym
    end

    mock_resources.select { |r| r[param_name] == param_value }
  end
end

module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def build_catalog_without_cache(nodename, facts_val, virt_res, exp_res, code)
      Puppet[:code] = code

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      virt_res = [virt_res] if virt_res.is_a? Hash
      exp_res = [exp_res] if exp_res.is_a? Hash

      scope = Puppet::Parser::Scope.new

      mock_virtual_resources = virt_res.map do |r|
        res = Puppet::Parser::Resource.new(r[:type], r[:title], {:virtual => true, :scope => scope})
        r[:parameters].keys.each { |k| res[k] = r[:parameters][k] }
        res
      end

      mock_exported_resources = exp_res.map do |r|
        res = Puppet::Parser::Resource.new(r[:type], r[:title], :virtual => true, :exported => true, :scope => scope)
        r[:parameters].keys.each { |k| res[k] = r[:parameters][k] }
        res
      end

      Puppet::Parser::Compiler.any_instance.stubs(:mock_resources).returns(mock_virtual_resources + mock_exported_resources)
      Puppet::Parser::Collector.any_instance.stubs(:mock_resources).returns(mock_exported_resources)

      require 'puppet/rails'
      Puppet::Rails.stubs(:init).returns(true)
      Puppet.features.stubs(:rails?).returns(true)
      Puppet.settings.set_value(:storeconfigs, true, :memory, :dont_trigger_handles => true)

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
