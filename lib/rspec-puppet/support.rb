require 'rspec-puppet/cache'
require 'rspec-puppet/adapters'
require 'rspec-puppet/raw_string'

module RSpec::Puppet
  module Support

    @@cache = RSpec::Puppet::Cache.new

    def subject
      lambda { catalogue }
    end

    def environment
      'rp_env'
    end

    def load_catalogue(type, exported = false)
      with_vardir do
        if Puppet.version.to_f >= 4.0 or Puppet[:parser] == 'future'
          code = [pre_cond, test_manifest(type)].compact.join("\n")
        else
          code = [import_str, pre_cond, test_manifest(type)].compact.join("\n")
        end

        node_name = nodename(type)

        hiera_config_value = self.respond_to?(:hiera_config) ? hiera_config : nil

        catalogue = build_catalog(node_name, facts_hash(node_name), hiera_config_value, code, exported)

        test_module = class_name.split('::').first
        RSpec::Puppet::Coverage.add_filter(type.to_s, self.class.description)
        RSpec::Puppet::Coverage.add_from_catalog(catalogue, test_module)

        catalogue
      end
    end

    def import_str
      import_str = ""
      adapter.modulepath.each { |d|
        if File.exists?(File.join(d, 'manifests', 'init.pp'))
          path_to_manifest = File.join([
            d,
            'manifests',
            class_name.split('::')[1..-1]
          ].flatten)
          import_str = [
            "import '#{d}/manifests/init.pp'",
            "import '#{path_to_manifest}.pp'",
            '',
          ].join("\n")
          break
        elsif File.exists?(d)
          import_str = "import '#{adapter.manifest}'\n"
          break
        end
      }

      import_str
    end

    def test_manifest(type)
      if type == :class
        if !self.respond_to?(:params) || params == {}
          "include #{class_name}"
        else
          "class { '#{class_name}': #{param_str} }"
        end
      elsif type == :application
        if self.respond_to? :params
          "site { #{class_name} { '#{title}': #{param_str} } }"
        else
          raise ArgumentException, "You need to provide params for an application"
        end
      elsif type == :define
        if self.respond_to? :params
          "#{class_name} { '#{title}': #{param_str} }"
        else
          "#{class_name} { '#{title}': }"
        end
      elsif type == :host
        nil
      end
    end

    def nodename(type)
      return node if self.respond_to?(:node)
      if [:class, :define, :function, :application].include? type
        Puppet[:certname]
      else
        class_name
      end
    end

    def class_name
      self.class.top_level_description.downcase
    end

    def pre_cond
      if self.respond_to?(:pre_condition) && !pre_condition.nil?
        if pre_condition.is_a? Array
          pre_condition.compact.join("\n")
        else
          pre_condition
        end
      else
        nil
      end
    end

    def facts_hash(node)
      facts_val = {
        'clientversion' => Puppet::PUPPETVERSION,
        'environment'   => environment,
        'hostname'      => node.split('.').first,
        'fqdn'          => node,
        'domain'        => node.split('.', 2).last,
        'clientcert'    => node
      }

      if RSpec.configuration.default_facts.any?
        facts_val.merge!(munge_facts(RSpec.configuration.default_facts))
      end

      facts_val.merge!(munge_facts(facts)) if self.respond_to?(:facts)
      facts_val
    end

    def param_str
      param_str_from_hash(params)
    end

    def str_from_value(value)
      case value
      when Hash
        kvs = value.collect do |k,v|
          "#{str_from_value(k)} => #{str_from_value(v)}"
        end.join(", ")
        "{ #{kvs} }"
      when :undef
        'undef'  # verbatim undef keyword
      else
        escape_special_chars(value.inspect)
      end
    end

    def param_str_from_hash(params_hash)
      # the param_str has special quoting rules, because the top-level keys are the Puppet
      # params, which may not be quoted
      params_hash.collect do |k,v|
        "#{k.to_s} => #{str_from_value(v)}"
      end.join(', ')
    end

    def setup_puppet
      vardir = Dir.mktmpdir
      Puppet[:vardir] = vardir

      # Enable app_management by default for Puppet versions that support it
      if Puppet.version.to_f >= 4.3
        Puppet[:app_management] = true
      end

      adapter.modulepath.map do |d|
        Dir["#{d}/*/lib"].entries
      end.flatten.each do |lib|
        $LOAD_PATH << lib
      end

      vardir
    end

    def with_vardir
      begin
        vardir = setup_puppet
        return yield(vardir) if block_given?
      ensure
        FileUtils.rm_rf(vardir) if File.directory?(vardir)
      end
    end

    def build_catalog_without_cache(nodename, facts_val, hiera_config_val, code, exported)

      # If we're going to rebuild the catalog, we should clear the cached instance
      # of Hiera that Puppet is using.  This opens the possibility of the catalog
      # now being rebuilt against a differently configured Hiera (i.e. :hiera_config
      # set differently in one example group vs. another).
      # It would be nice if Puppet offered a public API for invalidating their
      # cached instance of Hiera, but que sera sera.  We will go directly against
      # the implementation out of absolute necessity.
      HieraPuppet.instance_variable_set('@hiera', nil) if defined? HieraPuppet

      Puppet[:code] = code

      stub_facts! facts_val

      node_facts = Puppet::Node::Facts.new(nodename, facts_val.dup)

      node_obj = Puppet::Node.new(nodename, { :parameters => facts_val, :facts => node_facts })

      adapter.catalog(node_obj, exported)
    end

    def stub_facts!(facts)
      facts.each { |k, v| Facter.add(k) { setcode { v } } }
    end

    def build_catalog(*args)
      @@cache.get(*args) do |*args|
        build_catalog_without_cache(*args)
      end
    end

    # Facter currently supports lower case facts.  Bug FACT-777 has been submitted to support case sensitive
    # facts.
    def munge_facts(facts)
      return facts.reduce({}) do | memo, (k, v)|
        memo.tap { |m| m[k.to_s.downcase] = munge_facts(v) }
      end if facts.is_a? Hash

      return facts.reduce([]) do |memo, v|
        memo << munge_facts(v); memo
      end if facts.is_a? Array

      facts
    end

    def escape_special_chars(string)
      string.gsub!(/\$/, "\\$")
      string
    end

    def rspec_compatibility
      if RSpec::Version::STRING < '3'
        # RSpec 2 compatibility:
        alias_method :failure_message_for_should, :failure_message
        alias_method :failure_message_for_should_not, :failure_message_when_negated
      end
    end

    # Helper to return a resource/node reference, so it gets translated in params to a raw string
    # without quotes.
    #
    # @param [String] type reference type
    # @param [String] title reference title
    # @return [RSpec::Puppet::RawString] return a new RawString with the type/title populated correctly
    def ref(type, title)
      return RSpec::Puppet::RawString.new("#{type}['#{title}']")
    end

    # @!attribute [r] adapter
    #   @api private
    #   @return [Class < RSpec::Puppet::Adapters::Base]
    attr_accessor :adapter
  end
end
