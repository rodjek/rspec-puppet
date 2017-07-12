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

    def build_code(type, manifest_opts)
      if Puppet.version.to_f >= 4.0 or Puppet[:parser] == 'future'
        [site_pp_str, pre_cond, test_manifest(type, manifest_opts), post_cond].compact.join("\n")
      else
        [import_str, pre_cond, test_manifest(type, manifest_opts), post_cond].compact.join("\n")
      end
    end

    def guess_type_from_path(path)
      case path
      when /spec\/defines/
        :define
      when /spec\/classes/
        :class
      when /spec\/functions/
        :function
      when /spec\/hosts/
        :host
      when /spec\/types/
        :type
      when /spec\/type_aliases/
        :type_alias
      when /spec\/provider/
        :provider
      when /spec\/applications/
        :application
      else
        :unknown
      end
    end

    def stub_file_consts(example)
      if example.respond_to?(:metadata)
        type = example.metadata[:type]
      else
        type = guess_type_from_path(example.example.metadata[:file_path])
      end

      munged_facts = facts_hash(nodename(type))

      if munged_facts['operatingsystem'] && munged_facts['operatingsystem'].to_s.downcase == 'windows'
        stub_const_wrapper('File::PATH_SEPARATOR', ';')
        stub_const_wrapper('File::ALT_SEPARATOR', "\\")
        stub_const_wrapper('Pathname::SEPARATOR_PAT', /[#{Regexp.quote(File::ALT_SEPARATOR)}#{Regexp.quote(File::SEPARATOR)}]/)
      else
        stub_const_wrapper('File::PATH_SEPARATOR', ':')
        stub_const_wrapper('File::ALT_SEPARATOR', nil)
        stub_const_wrapper('Pathname::SEPARATOR_PAT', /#{Regexp.quote(File::SEPARATOR)}/)
      end
    end

    def stub_const_wrapper(const, value)
      if defined?(RSpec::Core::MockingAdapters::RSpec) && RSpec.configuration.mock_framework == RSpec::Core::MockingAdapters::RSpec
        stub_const(const, value)
      else
        klass_name, const_name = const.split('::', 2)
        klass = Object.const_get(klass_name)
        klass.send(:remove_const, const_name) if klass.const_defined?(const_name)
        klass.const_set(const_name, value)
      end
    end

    def load_catalogue(type, exported = false, manifest_opts = {})
      with_vardir do
        node_name = nodename(type)

        hiera_config_value = self.respond_to?(:hiera_config) ? hiera_config : nil
        hiera_data_value = self.respond_to?(:hiera_data) ? hiera_data : nil

        catalogue = build_catalog(node_name, facts_hash(node_name), trusted_facts_hash(node_name), hiera_config_value,
                                  build_code(type, manifest_opts), exported, node_params_hash, hiera_data_value)

        test_module = type == :host ? nil : class_name.split('::').first
        if type == :define
          RSpec::Puppet::Coverage.add_filter(class_name, title)
        else
          RSpec::Puppet::Coverage.add_filter(type.to_s, class_name)
        end
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

    def site_pp_str
      site_pp_str = ''
      filepath = adapter.manifest

      if (!filepath.nil?) && File.file?(filepath)
        site_pp_str = File.open(filepath).read
      end
      site_pp_str
    end

    def test_manifest(type, opts = {})
      opts[:params] = params if self.respond_to?(:params)

      if type == :class
        if opts[:params].nil? || opts[:params] == {}
          "include #{class_name}"
        else
          "class { '#{class_name}': #{param_str(opts[:params])} }"
        end
      elsif type == :application
        if opts.has_key?(:params)
          "site { #{class_name} { '#{title}': #{param_str(opts[:params])} } }"
        else
          raise ArgumentError, "You need to provide params for an application"
        end
      elsif type == :define
        title_str = if title.is_a?(Array)
                      '[' + title.map { |r| "'#{r}'" }.join(', ') + ']'
                    else
                      "'#{title}'"
                    end
        if opts.has_key?(:params)
          "#{class_name} { #{title_str}: #{param_str(opts[:params])} }"
        else
          "#{class_name} { #{title_str}: }"
        end
      elsif type == :host
        nil
      elsif type == :type_alias
        "$test = #{str_from_value(opts[:test_value])}\nassert_type(#{self.class.top_level_description}, $test)"
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

    def post_cond
      if self.respond_to?(:post_condition) && !post_condition.nil?
        if post_condition.is_a? Array
          post_condition.compact.join("\n")
        else
          post_condition
        end
      else
        nil
      end
    end

    def facts_hash(node)
      base_facts = {
        'clientversion' => Puppet::PUPPETVERSION,
        'environment'   => environment.to_s,
        'fqdn'          => node,
        'clientcert'    => node,
      }

      result_facts = if RSpec.configuration.default_facts.any?
                       munge_facts(RSpec.configuration.default_facts)
                     else
                       {}
                     end

      # Merge in `let(:facts)` facts
      result_facts.merge!(munge_facts(base_facts))
      result_facts.merge!(munge_facts(facts)) if self.respond_to?(:facts)

      # If `fqdn` was set but not hostname or domain, derive them from `fqdn` and add them:
      if result_facts.key?('fqdn')
        fqdn = result_facts['fqdn']
        result_facts['hostname'] = result_facts['fqdn'].split('.').first unless result_facts.key?('hostname')
        result_facts['domain'] = result_facts['fqdn'].split('.', 2).last unless result_facts.key?('domain')
      end

      # Set these three keys only if they weren't explicitly provided already in the networking
      # structured fact. This is to ensure that the user can override any of the facts, but
      # provides a helpful default setting in the networking hash similar to the previous behavior
      # in the top-level facts:
      result_facts['networking'] = {} unless result_facts.key?('networking')
      ['hostname', 'fqdn', 'domain'].each do |fact|
        result_facts['networking'][fact] = result_facts[fact] unless result_facts['networking'].key?(fact)
      end

      # Facter currently supports lower case facts.  Bug FACT-777 has been submitted to support case sensitive
      # facts.
      downcase_facts = Hash[result_facts.map { |k, v| [k.downcase, v] }]
      downcase_facts
    end

    def node_params_hash
      params = RSpec.configuration.default_node_params
      if respond_to?(:node_params)
        params.merge(node_params)
      else
        params.dup
      end
    end

    def param_str(params)
      param_str_from_hash(params)
    end

    def trusted_facts_hash(node_name)
      return {} unless Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0

      extensions = {}

      if RSpec.configuration.default_trusted_facts.any?
        extensions.merge!(RSpec.configuration.default_trusted_facts)
      end

      extensions.merge!(trusted_facts) if self.respond_to?(:trusted_facts)
      extensions
    end

    def str_from_value(value)
      case value
      when Hash
        kvs = value.collect do |k,v|
          "#{str_from_value(k)} => #{str_from_value(v)}"
        end.join(", ")
        "{ #{kvs} }"
      when Array
        vals = value.map do |v|
          str_from_value(v)
        end.join(", ")
        "[ #{vals} ]"
      when :default
        'default'  # verbatim default keyword
      when :undef
        'undef'  # verbatim undef keyword
      when Symbol
        str_from_value(value.to_s)
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
      if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 && Puppet.version.to_i < 5
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
        FileUtils.rm_rf(vardir) if vardir && File.directory?(vardir)
      end
    end

    def build_catalog_without_cache(nodename, facts_val, trusted_facts_val, hiera_config_val, code, exported, node_params, *_)

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
      node_params = facts_val.merge(node_params)

      node_obj = Puppet::Node.new(nodename, { :parameters => node_params, :facts => node_facts })

      if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
        Puppet.push_context(
          {
            :trusted_information => Puppet::Context::TrustedInformation.new('remote', nodename, trusted_facts_val)
          },
          "Context for spec trusted hash"
        )
      end

      adapter.catalog(node_obj, exported)
    end

    def stub_facts!(facts)
      if facts['operatingsystem'] && facts['operatingsystem'].to_s.downcase == 'windows'
        Puppet::Util::Platform.pretend_to_be :windows
      else
        Puppet::Util::Platform.pretend_to_be :posix
      end
      Puppet.settings[:autosign] = false
      facts.each { |k, v| Facter.add(k) { setcode { v } } }
    end

    def build_catalog(*args)
      @@cache.get(*args) do |*args|
        build_catalog_without_cache(*args)
      end
    end

    def munge_facts(facts)
      return facts.reduce({}) do | memo, (k, v)|
        memo.tap { |m| m[k.to_s] = munge_facts(v) }
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
