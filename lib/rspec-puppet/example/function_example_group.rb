module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      function_name = self.class.top_level_description.downcase

      if self.respond_to? :module_path
        Puppet[:modulepath] = module_path
      else
        Puppet[:modulepath] = RSpec.configuration.module_path
      end

      Puppet[:libdir] = Dir["#{Puppet[:modulepath]}/*/lib"].entries.join(File::PATH_SEPARATOR)

      nodename = self.respond_to?(:node) ? node : Puppet[:certname]
      facts_val = {
        'hostname' => nodename.split('.').first,
        'fqdn'     => nodename,
        'domain'   => nodename.split('.').last,
      }

      if RSpec.configuration.default_facts.any?
        facts_val.merge!(munge_facts(RSpec.configuration.default_facts))
      end

      facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)

      stub_facts! facts_val

      # if we specify a pre_condition, we should ensure that we compile that code
      # into a catalog that is accessible from the scope where the function is called
      if self.respond_to? :pre_condition
        if pre_condition.kind_of?(Array)
          Puppet[:code] = pre_condition.join("\n")
        else
          Puppet[:code] = pre_condition
        end
      end

      compiler = build_compiler(nodename, facts_val)

      function_scope = scope(compiler, nodename)

      # Return the method instance for the function.  This can be used with
      # method.call
      return nil unless Puppet::Parser::Functions.function(function_name)
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
