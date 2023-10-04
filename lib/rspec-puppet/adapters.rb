# frozen_string_literal: true

require 'rspec-puppet/facter_impl'

module RSpec::Puppet
  module Adapters
    class Base
      # Set up all Puppet settings applicable for this Puppet version as
      # application defaults.
      #
      # Puppet setting values can be taken from the global RSpec configuration, or from the currently
      # executing RSpec context. When a setting is specified both in the global configuration and in
      # the example group, the setting in the example group is preferred.
      #
      # @example Configuring a Puppet setting from within an RSpec example group
      #   RSpec.describe 'my_module::my_class', :type => :class do
      #     let(:module_path) { "/Users/luke/modules" }
      #     #=> Puppet[:modulepath] will be "/Users/luke/modules"
      #   end
      #
      # @example Configuring a Puppet setting with both a global RSpec configuration and local context
      #   RSpec.configure do |config|
      #     config.confdir = "/etc/puppet"
      #   end
      #   RSpec.describe 'my_module', :type => :class do
      #     # Puppet[:confdir] will be "/etc/puppet"
      #   end
      #   RSpec.describe 'my_module::my_class', :type => :class do
      #     let(:confdir) { "/etc/puppetlabs/puppet" }
      #     # => Puppet[:confdir] will be "/etc/puppetlabs/puppet" in this example group
      #   end
      #   RSpec.describe 'my_module::my_define', :type => :define do
      #     # Puppet[:confdir] will be "/etc/puppet" again
      #   end
      #
      # @param example_group [RSpec::Core::ExampleGroup] The RSpec context to use for local settings
      # @return [void]
      def setup_puppet(example_group)
        case RSpec.configuration.facter_implementation.to_sym
        when :rspec
          # Lazily instantiate FacterTestImpl here to optimize memory
          # allocation, as the proc will only be called if FacterImpl is unset
          set_facter_impl(proc { RSpec::Puppet::FacterTestImpl.new })
        when :facter
          set_facter_impl(Facter)
        else
          raise "Unsupported facter_implementation '#{RSpec.configuration.facter_implementation}'"
        end

        Puppet.runtime[:facter] = FacterImpl

        settings = settings_map.map do |puppet_setting, rspec_setting|
          [puppet_setting, get_setting(example_group, rspec_setting)]
        end.flatten
        default_hash = { confdir: '/dev/null', vardir: '/dev/null' }
        if defined?(Puppet::Test::TestHelper) && Puppet::Test::TestHelper.respond_to?(:app_defaults_for_tests, true)
          default_hash.merge!(Puppet::Test::TestHelper.send(:app_defaults_for_tests))
        end
        settings_hash = default_hash.merge(Hash[*settings])
        if Gem.win_platform?
          settings_hash.each_with_object(settings_hash) do |(k, v), h|
            h[k] = v == '/dev/null' ? 'c:/nul/' : v
          end
        end

        Puppet.settings.initialize_app_defaults(settings_hash)

        # Forcefully apply the environmentpath setting instead of relying on
        # the application defaults as Puppet::Test::TestHelper automatically
        # sets this value as well, overriding our application default
        Puppet.settings[:environmentpath] = settings_hash[:environmentpath] if settings_hash.key?(:environmentpath)

        @environment_name = example_group.environment

        modulepath = if (rspec_modulepath = RSpec.configuration.module_path)
                       rspec_modulepath.split(File::PATH_SEPARATOR)
                     else
                       Puppet[:environmentpath].split(File::PATH_SEPARATOR).map do |path|
                         File.join(path, 'fixtures', 'modules')
                       end
                     end

        if (rspec_manifest = RSpec.configuration.manifest)
          manifest = rspec_manifest
        else
          manifest_paths = Puppet[:environmentpath].split(File::PATH_SEPARATOR).map do |path|
            File.join(path, 'fixtures', 'manifests')
          end

          manifest = manifest_paths.find do |path|
            File.exist?(path)
          end

          manifest ||= Puppet::Node::Environment::NO_MANIFEST
        end

        env = Puppet::Node::Environment.create(@environment_name, modulepath, manifest)
        loader = Puppet::Environments::Static.new(env)

        Puppet.push_context(
          {
            environments: loader,
            current_environment: env,
            loaders: Puppet::Pops::Loaders.new(env)
          },
          'Setup rspec-puppet environments'
        )
      end

      def get_setting(example_group, rspec_setting)
        if example_group.respond_to?(rspec_setting)
          example_group.send(rspec_setting)
        else
          RSpec.configuration.send(rspec_setting)
        end
      end

      def catalog(node, exported)
        node.environment = current_environment
        # Override $::environment to workaround PUP-5835, where Puppet otherwise
        # stores a symbol for the parameter
        if node.parameters['environment'] != node.parameters['environment'].to_s
          node.parameters['environment'] = current_environment.name.to_s
        end

        catalog = if exported
                    # Use the compiler directly to skip the filtering done by the indirector
                    Puppet::Parser::Compiler.compile(node).filter { |r| !r.exported? }
                  else
                    Puppet::Resource::Catalog.indirection.find(node.name, use_node: node)
                  end

        Puppet::Pops::Evaluator::DeferredResolver.resolve_and_replace(node.facts, catalog)

        catalog
      end

      def current_environment
        Puppet::Node::Environment.new(@environment_name)
      end

      def settings_map
        [
          %i[modulepath module_path],
          %i[basemodulepath basemodulepath],
          %i[config config],
          %i[confdir confdir],
          %i[environmentpath environmentpath],
          %i[hiera_config hiera_config],
          %i[strict_variables strict_variables],
          %i[vendormoduledir vendormoduledir]
        ]
      end

      def current_environment
        Puppet.lookup(:current_environment)
      end

      def modulepath
        current_environment.modulepath
      end

      # @return [String, nil] The path to the Puppet manifest if it is present and set, nil otherwise.
      def manifest
        m = current_environment.manifest
        if m == Puppet::Node::Environment::NO_MANIFEST
          nil
        else
          m
        end
      end

      # @api private
      #
      # Set the FacterImpl constant to the given Facter implementation or noop
      # if the constant is already set. If a proc is given, it will only be
      # called if FacterImpl is not defined.
      #
      # @param impl [Object, Proc] An object or a proc that implements the Facter API
      def set_facter_impl(impl)
        return if defined?(FacterImpl)

        impl = impl.call if impl.is_a?(Proc)
        Object.send(:const_set, :FacterImpl, impl)
      end
    end

    def self.get
      [
        ['7.11', Base]
      ].each do |(version, klass)|
        return klass.new if Puppet::Util::Package.versioncmp(Puppet.version, version) >= 0
      end
      raise "Puppet version #{Puppet.version} is not supported."
    end
  end
end
