class Puppet::Parser::Compiler
  def compile
    set_node_parameters
    create_settings_scope

    evaluate_main

    evaluate_ast_node

    mock_virtual_resources.each do |r|
      add_resource(topscope, r)
    end


    evaluate_node_classes

    evaluate_generators

    finish

    fail_on_unevaluated

    @catalog
  end
end

module RSpec::Puppet
  module Support
    def build_catalog(nodename, facts_val, additional_resources)
      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      additional_resources = [additional_resources] if additional_resources.is_a? Hash
      scope = Puppet::Parser::Scope.new
      additional_resources = additional_resources.map do |r|
        res = Puppet::Parser::Resource.new(r[:type], r[:title], {:virtual => true, :scope => scope})
        r[:parameters].keys.each { |k|
        res[k] = r[:parameters][k]
        }
        res
      end

      Puppet::Parser::Compiler.any_instance.stub(:mock_virtual_resources).and_return(additional_resources)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        catalogue = Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        require 'puppet/face'
        catalogue = Puppet::Face[:catalog, :current].find(node_obj.name, :use_node => node_obj)
      end

      catalogue
    end
  end
end
