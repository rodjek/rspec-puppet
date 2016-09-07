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
      def execute(*args)
        Puppet.override(@overrides, "rspec-test scope") do
          @func.call(@overrides[:global_scope], *args)
        end
      end

      # compatibility alias for existing tests
      def call(scope, *args)
        RSpec.deprecate("subject.call", :replacement => "is_expected.to run.with().and_raise_error(), or execute()")
        execute(*args)
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

    def find_function
      function_name = self.class.top_level_description.downcase

      with_vardir do
        env = adapter.current_environment

        if Puppet.version.to_f >= 4.0
          context_overrides = compiler.context_overrides
          func = nil
          Puppet.override(context_overrides, "rspec-test scope") do
            loader = Puppet::Pops::Loaders.new(env)
            func = V4FunctionWrapper.new(function_name, loader.private_environment_loader.load(:function, function_name), context_overrides)
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
