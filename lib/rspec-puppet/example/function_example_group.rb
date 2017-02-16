module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    class V4FunctionWrapper
      attr_reader :func, :func_name

      def initialize(name, func, overrides)
        @func_name = name
        @func = func
        @overrides = overrides
      end

      # This method is used by the `run` matcher to trigger the function execution, and provides a uniform interface across all puppet versions.
      def execute(*args, &block)
        Puppet.override(@overrides, "rspec-test scope") do
          @func.call(@overrides[:global_scope], *freeze_arg(args), &block)
        end
      end

      # compatibility alias for existing tests
      def call(scope, *args)
        RSpec.deprecate("subject.call", :replacement => "is_expected.to run.with().and_raise_error(), or execute()")
        execute(*args)
      end

      private

      # Facts, keywords, single-quoted strings etc. are usually frozen in Puppet manifests, so freeze arguments to ensure functions are tested
      # under worst-case conditions.
      def freeze_arg(arg)
        case arg
        when Array
          arg.each { |a| freeze_arg(a) }
          arg.freeze
        when Hash
          arg.each { |k,v| freeze_arg(k); freeze_arg(v) }
          arg.freeze
        when String
          arg.freeze
        end
        arg
      end
    end

    class V3FunctionWrapper
      attr_accessor :func_name

      def initialize(name, func)
        @func_name = name
        @func = func
      end

      # This method is used by the `run` matcher to trigger the function execution, and provides a uniform interface across all puppet versions.
      def execute(*args)
        if args.nil?
          @func.call
        else
          @func.call(args)
        end
      end

      # This method was formerly used by the `run` matcher to trigger the function execution, and provides puppet versions dependant interface.
      def call(*args)
        RSpec.deprecate("subject.call", :replacement => "is_expected.to run.with().and_raise_error(), or execute()")
        if args.nil?
          @func.call
        else
          @func.call(*args)
        end
      end
    end

    # (at least) rspec 3.5 doesn't seem to memoize `subject` when called from
    # a before(:each) hook, so we need to memoize it ourselves.
    def subject
      @subject ||= find_function
    end

    def find_function(function_name = self.class.top_level_description)
      with_vardir do
        env = adapter.current_environment

        if Puppet.version.to_f >= 4.0
          context_overrides = compiler.context_overrides
          func = nil
          loaders = Puppet.lookup(:loaders)
          Puppet.override(context_overrides, "rspec-test scope") do
            func = V4FunctionWrapper.new(function_name, loaders.private_environment_loader.load(:function, function_name), context_overrides)
            @scope = context_overrides[:global_scope]
          end

          return func if func.func
        end

        if Puppet::Parser::Functions.function(function_name)
          V3FunctionWrapper.new(function_name, scope.method("function_#{function_name}".intern))
        else
          nil
        end
      end
    end
    def call_function(function_name, *args)
#      function = find_function(function_name)
#      function.execute(*args)
     scope.call_function(function_name, args)
    end
    def scope
      @scope ||= build_scope(compiler, nodename(:function))
    end

    def catalogue
      @catalogue ||= compiler.catalog
    end

    def rspec_puppet_cleanup
      @subject = nil
      @catalogue = nil
      @compiler = nil
      @scope = nil
    end

    private

    def compiler
      @compiler ||= build_compiler
    end

    # get a compiler with an attached compiled catalog
    def build_compiler
      node_name   = nodename(:function)
      fact_values = facts_hash(node_name)
      trusted_values = trusted_facts_hash(node_name)

      # Allow different Hiera configurations:
      HieraPuppet.instance_variable_set('@hiera', nil) if defined? HieraPuppet

      # if we specify a pre_condition, we should ensure that we compile that
      # code into a catalog that is accessible from the scope where the
      # function is called
      Puppet[:code] = pre_cond

      node_facts = Puppet::Node::Facts.new(node_name, fact_values.dup)

      node_options = {
        :parameters => fact_values,
        :facts => node_facts
      }

      stub_facts! fact_values

      node = build_node(node_name, node_options)

      if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
        Puppet.push_context(
          {
            :trusted_information => Puppet::Context::TrustedInformation.new('remote', node_name, trusted_values)
          },
          "Context for spec trusted hash"
        )
      end

      compiler = Puppet::Parser::Compiler.new(node)
      compiler.compile
      if Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
        loaders = Puppet::Pops::Loaders.new(adapter.current_environment)
        Puppet.push_context(
          {
            :loaders => loaders,
            :global_scope => compiler.context_overrides[:global_scope]
          },
        "set globals")
      end
      compiler
    end

    def build_scope(compiler, node_name)
      if Puppet.version.to_f >= 4.0
        return compiler.context_overrides[:global_scope]
      elsif Puppet.version =~ /^2\.[67]/
        # loadall should only be necessary prior to 3.x
        # Please note, loadall needs to happen first when creating a scope, otherwise
        # you might receive undefined method `function_*' errors
        Puppet::Parser::Functions.autoloader.loadall
        scope = Puppet::Parser::Scope.new(:compiler => compiler)
      else
        scope = Puppet::Parser::Scope.new(compiler)
      end

      scope.source = Puppet::Resource::Type.new(:node, node_name)
      scope.parent = compiler.topscope
      scope
    end

    def build_node(name, opts = {})
      node_environment = adapter.current_environment
      opts.merge!({:environment => node_environment})
      Puppet::Node.new(name, opts)
    end
  end
end
