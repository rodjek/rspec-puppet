module RSpec::Puppet
  module Support

    @@cache = {}

    def catalogue(type)
      vardir = setup_puppet

      code = [import_str, pre_cond, test_manifest(type)].join("\n")
      node_name = nodename(type)

      catalogue = build_catalog(node_name, facts_hash(node_name), code)
      FileUtils.rm_rf(vardir) if File.directory?(vardir)
      catalogue
    end

    def import_str
      klass_name = self.class.top_level_description.downcase

      if File.exists?(File.join(Puppet[:modulepath], 'manifests', 'init.pp'))
        path_to_manifest = File.join([
          Puppet[:modulepath],
          'manifests',
          klass_name.split('::')[1..-1]
        ].flatten)
        import_str = [
          "import '#{Puppet[:modulepath]}/manifests/init.pp'",
          "import '#{path_to_manifest}.pp'",
          '',
        ].join("\n")
      elsif File.exists?(Puppet[:modulepath])
        import_str = "import '#{Puppet[:manifest]}'\n"
      else
        import_str = ""
      end

      import_str
    end

    def test_manifest(type)
      klass_name = self.class.top_level_description.downcase

      if type == :class
        if !self.respond_to?(:params) || params == {}
          "include #{klass_name}"
        else
          "class { '#{klass_name}': #{param_str} }"
        end
      elsif type == :define
        if self.respond_to? :params
          "#{klass_name} { '#{title}': #{param_str} }"
        else
          "#{klass_name} { '#{title}': }"
        end
      elsif type == :host
        ""
      end
    end

    def nodename(type)
      if [:class, :define, :function].include? type
        self.respond_to?(:node) ? node : Puppet[:certname]
      else
        self.class.top_level_description.downcase
      end
    end


    def pre_cond
      if self.respond_to?(:pre_condition) && !pre_condition.nil?
        if pre_condition.is_a? Array
          pre_condition.join("\n")
        else
          pre_condition
        end
      else
        ''
      end
    end

    def facts_hash(node)
      facts_val = {
        'hostname' => node.split('.').first,
        'fqdn'     => node,
        'domain'   => node.split('.', 2).last,
      }

      if RSpec.configuration.default_facts.any?
        facts_val.merge!(munge_facts(RSpec.configuration.default_facts))
      end

      facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)
      facts_val
    end

    def param_str
      params.keys.map do |r|
        param_val = escape_special_chars(params[r].inspect)
        "#{r.to_s} => #{param_val}"
      end.join(', ')
    end

    def setup_puppet
      vardir = Dir.mktmpdir
      Puppet[:vardir] = vardir

      [
        [:modulepath, :module_path],
        [:manifestdir, :manifest_dir],
        [:manifest, :manifest],
        [:templatedir, :template_dir],
        [:config, :config],
        [:confdir, :confdir],
        [:hiera_config, :hiera_config],
      ].each do |a, b|
        value = self.respond_to?(b) ? self.send(b) : RSpec.configuration.send(b)
        begin
          Puppet[a] = value
        rescue ArgumentError
          Puppet.settings.setdefaults(:main, {a => {:default => value, :desc => a.to_s}})
        end
      end

      Puppet[:libdir] = Dir["#{Puppet[:modulepath]}/*/lib"].entries.join(File::PATH_SEPARATOR)
      vardir
    end

    def build_catalog_without_cache(nodename, facts_val, code)
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

    def stub_facts!(facts)
      facts.each { |k, v| Facter.add(k) { setcode { v } } }
    end

    def build_catalog(*args)
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
