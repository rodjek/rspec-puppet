require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers
    PuppetInternals = PuppetlabsSpec::PuppetInternals

    def subject
      function_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:libdir] = Dir["#{Puppet[:modulepath]}/*/lib"].entries.join(File::PATH_SEPARATOR)

      # if we specify a pre_condition, we should ensure that we compile that code
      # into a catalog that is accessible from the scope where the function is called
      if self.respond_to? :pre_condition
        if pre_condition.kind_of?(Array)
          Puppet[:code] = pre_condition.join("\n")
        else
          Puppet[:code] = pre_condition
        end
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
        @compiler = PuppetInternals.compiler
      end

      scope = PuppetInternals.scope(:compiler => @compiler)
      Puppet.initialize_settings

      # Return the method instance for the function.  This can be used with
      # method.call
      method = PuppetInternals.function_method(function_name, :scope => scope)
    end

    def compiler
      @compiler
    end

    # get a compiler with an attached compiled catalog
    def build_compiler(node_name, fact_values)
      node_options = {
        :name    => node_name,
        :options => { :parameters => fact_values },
      }
      node = PuppetInternals.node(node_options)
      compiler = PuppetInternals.compiler(:node => node)
      compiler.compile
      compiler
    end
  end
end
