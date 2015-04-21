module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      function_name = self.class.top_level_description.downcase

      vardir = setup_puppet

      node_name = nodename(:function)

      if Puppet.version.to_f >= 4.0
        env = Puppet::Node::Environment.create(environment, [File.join(Puppet[:environmentpath],'fixtures','modules')], File.join(Puppet[:environmentpath],'fixtures','manifests'))
        loader = Puppet::Pops::Loaders.new(env)
        func = loader.private_environment_loader.load(:function,function_name)
        return func if func
      end

      function_scope = scope(compiler, node_name)

      # Return the method instance for the function.  This can be used with
      # method.call
      if env
        return nil unless Puppet::Parser::Functions.function(function_name,env)
      else
        return nil unless Puppet::Parser::Functions.function(function_name)
      end
      FileUtils.rm_rf(vardir) if File.directory?(vardir)
      function_scope.method("function_#{function_name}".intern)
    end

    def catalogue
      @catalogue ||= compiler.catalog
    end

    private

    def compiler
      @compiler ||= build_compiler
    end

    # get a compiler with an attached compiled catalog
    def build_compiler
      node_name   = nodename(:function)
      fact_values = facts_hash(node_name)

      # if we specify a pre_condition, we should ensure that we compile that
      # code into a catalog that is accessible from the scope where the
      # function is called
      Puppet[:code] = pre_cond

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
