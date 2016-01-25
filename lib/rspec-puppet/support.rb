require 'rspec-puppet/cache'
require 'rspec-puppet/adapters'

module RSpec::Puppet
  module Support

    @@cache = RSpec::Puppet::Cache.new

    def subject
      lambda { catalogue }
    end

    def environment
      # unfreeze PUPPETVERSION because of https://github.com/bundler/bundler/issues/3187
      ver = Gem::Version.new("#{Puppet::PUPPETVERSION}")
      # Since applying a fix for PUP-5522 (puppet 3.8.5 and 4.3.2) puppet symbolizes environment names
      # internally. The catalog cache needs to assume that the facts and other args do not change between
      # runs, so we have to mirror this here. Puppet versions before the change require a string as environment
      # name, or they fail with "Unsupported data type: 'Symbol' on node xyz"
      # See https://github.com/rodjek/rspec-puppet/pull/354 and PUP-5743 for discussion of this
      if (Gem::Version.new('3.8.5') <= ver && ver < Gem::Version.new('4.0.0')) || Gem::Version.new('4.3.2') <= ver
        :rp_env
      else
        'rp_env'
      end
    end

    def load_catalogue(type)
      vardir = setup_puppet

      if Puppet.version.to_f >= 4.0 or Puppet[:parser] == 'future'
        code = [pre_cond, test_manifest(type)].compact.join("\n")
      else
        code = [import_str, pre_cond, test_manifest(type)].compact.join("\n")
      end

      node_name = nodename(type)

      hiera_config_value = self.respond_to?(:hiera_config) ? hiera_config : nil

      catalogue = build_catalog(node_name, facts_hash(node_name), hiera_config_value, code)

      test_module = class_name.split('::').first
      RSpec::Puppet::Coverage.add_filter(type.to_s, self.class.description)
      RSpec::Puppet::Coverage.add_from_catalog(catalogue, test_module)

      FileUtils.rm_rf(vardir) if File.directory?(vardir)
      catalogue
    end

    def import_str
      import_str = ""
      Puppet[:modulepath].split(File::PATH_SEPARATOR).each { |d|
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
          import_str = "import '#{Puppet[:manifest]}'\n"
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
      if [:class, :define, :function].include? type
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
      params.keys.map do |r|
        param_val = params[r]
        param_val_str = if param_val == :undef
                          'undef'  # verbatim undef keyword
                        else
                          escape_special_chars(param_val.inspect)
                        end
        "#{r.to_s} => #{param_val_str}"
      end.join(', ')
    end

    def setup_puppet
      vardir = Dir.mktmpdir
      Puppet[:vardir] = vardir

      adapter.setup_puppet(self)

      Puppet[:modulepath].split(File::PATH_SEPARATOR).map do |d|
        Dir["#{d}/*/lib"].entries
      end.flatten.each do |lib|
        $LOAD_PATH << lib
      end

      vardir
    end

    def build_catalog_without_cache(nodename, facts_val, hiera_config_val, code)

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

      adapter.catalog(node_obj, environment)
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

    def adapter
      @adapter ||= RSpec::Puppet::Adapters.get
    end
  end
end
