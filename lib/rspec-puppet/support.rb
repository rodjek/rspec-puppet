module RSpec::Puppet
  module Support

    @@cache = {}

    protected
    def build_catalog_without_cache(nodename, facts_val, code)
      if Integer(Puppet.version.split('.').first) >= 3
#        Puppet.initialize_settings unless Puppet.global_defaults_initialized?
      end

      Puppet[:code] = code

      stub_facts! facts_val

      node_obj = Puppet::Node.new(nodename)

      node_obj.merge(facts_val)

      # trying to be compatible with 2.7 as well as 2.6
      if Puppet::Resource::Catalog.respond_to? :find
        Puppet::Resource::Catalog.find(node_obj.name, :use_node => node_obj)
      else
        Puppet::Resource::Catalog.indirection.find(node_obj.name, :use_node => node_obj)
      end
    end

    public
    def stub_facts!(facts)
      facts.each { |k, v| Facter.add(k) { setcode { v } } }
    end

    def build_catalog *args
      @@cache[args] ||= self.build_catalog_without_cache(*args)
    end

    def munge_facts(facts)
      output = {}
      facts.keys.each { |key| output[key.to_s] = facts[key] }
      output
    end

    def escape_special_chars(string)
      string.gsub!(/\$/, "\\$")
      string
    end

    def scope(compiler, node_name)
      if Puppet.version =~ /^2\.[67]/
        # loadall should only be necessary prior to 3.x
        # Please note, loadall needs to happen first when creating a scope, otherwise
        # you might receive undefined method `function_*' errors
        Puppet::Parser::Functions.autoloader.loadall
      end

      if Puppet.version =~ /^2\.[67]/
        scope = Puppet::Parser::Scope.new(:compiler => compiler)
      else
        scope = Puppet::Parser::Scope.new(compiler)
      end

      scope.source = Puppet::Resource::Type.new(:node, node_name)
      scope.parent = compiler.topscope
      scope
    end

    def build_node(name, opts = {})
      node_environment = Puppet::Node::Environment.new('test')
      opts.merge!({:environment => node_environment})
      Puppet::Node.new(name, opts)
    end
  end
end
