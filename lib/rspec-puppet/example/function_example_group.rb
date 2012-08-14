module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers

    def subject
      function_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:libdir] = Dir["#{Puppet[:modulepath]}/*/lib"].entries.join(File::PATH_SEPARATOR)
      Puppet::Parser::Functions.autoloader.loadall

      # if we specify a pre_condition, we should ensure that we compile that code
      # into a catalog that is accessible from the scope where the function is called
      if self.respond_to? :pre_condition
        Puppet[:code] = pre_condition
        nodename = self.respond_to?(:node) ? node : Puppet[:certname]
        facts_val = {
          'hostname' => nodename.split('.').first,
          'fqdn' => nodename,
          'domain' => nodename.split('.').last,
        }
        facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)
        # we need to get a compiler, b/c we can attach that to a scope
        @compiler = build_compiler(nodename, facts_val)
      else
        @compiler = nil
      end

      scope = Puppet::Parser::Scope.new(:compiler => @compiler)

      Puppet::Parser::Functions.function(function_name)

      scope.method "function_#{function_name}".to_sym
    end

    def compiler
      @compiler
    end
    # get a compiler with an attached compiled catalog
    def build_compiler(node_name, fact_values)
      compiler = Puppet::Parser::Compiler.new(Puppet::Node.new(node_name, :parameters => fact_values))
      compiler.compile
      compiler
    end
  end
end
