module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      function_name = self.class.top_level_description.downcase

      vardir = setup_puppet

      node_name = nodename(:function)

      facts_val = facts_hash(node_name)

      # if we specify a pre_condition, we should ensure that we compile that code
      # into a catalog that is accessible from the scope where the function is called
      Puppet[:code] = pre_cond

      compiler = build_compiler(node_name, facts_val)

      function_scope = scope(compiler, node_name)

      # Return the method instance for the function.  This can be used with
      # method.call
      return nil unless Puppet::Parser::Functions.function(function_name)
      FileUtils.rm_rf(vardir) if File.directory?(vardir)
      function_scope.method("function_#{function_name}".intern)
    end

    # get a compiler with an attached compiled catalog
    def build_compiler(node_name, fact_values)
      node_options = {
        :parameters => fact_values,
      }

      stub_facts! fact_values

      node = build_node(node_name, node_options)

      compiler = Puppet::Parser::Compiler.new(node)
      compiler.compile
      compiler
    end
  end
end
