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
      # @example Configuring a Puppet setting from a global RSpec configuration value
      #   RSpec.configure do |config|
      #     config.parser = "future"
      #   end
      #   # => Puppet[:parser] will be future
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
        settings = settings_map.map do |puppet_setting, rspec_setting|
          [puppet_setting, get_setting(example_group, rspec_setting)]
        end.flatten
        default_hash = {:confdir => '/dev/null', :vardir => '/dev/null' }
        if defined?(Puppet::Test::TestHelper) && Puppet::Test::TestHelper.respond_to?(:app_defaults_for_tests, true)
          default_hash.merge!(Puppet::Test::TestHelper.send(:app_defaults_for_tests))
        end
        settings_hash = default_hash.merge(Hash[*settings])
        settings_hash.inject(settings_hash) { |h, (k, v)| h[k] = (v == '/dev/null') ? 'c:/nul/' : v; h } if Gem.win_platform?

        if Puppet.settings.respond_to?(:initialize_app_defaults)
          Puppet.settings.initialize_app_defaults(settings_hash)

          # Forcefully apply the environmentpath setting instead of relying on
          # the application defaults as Puppet::Test::TestHelper automatically
          # sets this value as well, overriding our application default
          Puppet.settings[:environmentpath] = settings_hash[:environmentpath] if settings_hash.key?(:environmentpath)
        else
          # Set settings the old way for Puppet 2.x, because that's how
          # they're defaulted in that version of Puppet::Test::TestHelper and
          # we won't be able to override them otherwise.
          settings_hash.each do |setting, value|
            Puppet.settings[setting] = value
          end
        end

        @environment_name = example_group.environment
      end

      def get_setting(example_group, rspec_setting)
        if example_group.respond_to?(rspec_setting)
          example_group.send(rspec_setting)
        else
          RSpec.configuration.send(rspec_setting)
        end
      end

      def catalog(node, exported)
        if exported
          # Use the compiler directly to skip the filtering done by the indirector
          Puppet::Parser::Compiler.compile(node).filter { |r| !r.exported? }
        else
          Puppet::Resource::Catalog.indirection.find(node.name, :use_node => node)
        end
      end

      def current_environment
        Puppet::Node::Environment.new(@environment_name)
      end

      def settings_map
        [
          [:modulepath, :module_path],
          [:config, :config],
          [:confdir, :confdir],
        ]
      end

      def modulepath
        Puppet[:modulepath].split(File::PATH_SEPARATOR)
      end

      # @return [String, nil] The path to the Puppet manifest if it is present and set, nil otherwise.
      def manifest
        Puppet[:manifest]
      end
    end

    class Adapter40 < Base
      def setup_puppet(example_group)
        super

        if rspec_modulepath = RSpec.configuration.module_path
          modulepath = rspec_modulepath.split(File::PATH_SEPARATOR)
        else
          modulepath = Puppet[:environmentpath].split(File::PATH_SEPARATOR).map do |path|
            File.join(path, 'fixtures', 'modules')
          end
        end

        if rspec_manifest = RSpec.configuration.manifest
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
            :environments => loader,
            :current_environment => env
          },
          "Setup rspec-puppet environments"
        )
      end

      def settings_map
        super.concat([
          [:environmentpath, :environmentpath],
          [:hiera_config, :hiera_config],
          [:strict_variables, :strict_variables],
          [:manifest, :manifest],
        ])
      end

      def catalog(node, exported)
        node.environment = current_environment
        # Override $::environment to workaround PUP-5835, where Puppet otherwise
        # stores a symbol for the parameter
        node.parameters['environment'] = current_environment.name.to_s if node.parameters['environment'] != node.parameters['environment'].to_s
        super
      end

      def current_environment
        Puppet.lookup(:current_environment)
      end

      def modulepath
        current_environment.modulepath
      end

      # Puppet 4.0 specially handles environments that don't have a manifest set, so we check for the no manifest value
      # and return nil when it is set.
      #
      # @return [String, nil] The path to the Puppet manifest if it is present and set, nil otherwise.
      def manifest
        m = current_environment.manifest
        if m == Puppet::Node::Environment::NO_MANIFEST
          nil
        else
          m
        end
      end
    end

    class Adapter4X < Adapter40
      def settings_map
        super.concat([
          [:trusted_server_facts, :trusted_server_facts]
        ])
      end
    end

    class Adapter30 < Base
      def settings_map
        super.concat([
          [:manifestdir, :manifest_dir],
          [:manifest, :manifest],
          [:templatedir, :template_dir],
          [:hiera_config, :hiera_config],
        ])
      end
    end

    class Adapter32 < Adapter30
      def settings_map
        super.concat([
          [:parser, :parser],
        ])
      end
    end

    class Adapter33 < Adapter32
      def settings_map
        super.concat([
          [:ordering, :ordering],
          [:stringify_facts, :stringify_facts],
        ])
      end
    end

    class Adapter34 < Adapter33
      def settings_map
        super.concat([
          [:trusted_node_data, :trusted_node_data],
        ])
      end
    end

    class Adapter35 < Adapter34
      def settings_map
        super.concat([
          [:strict_variables, :strict_variables],
        ])
      end
    end

    class Adapter27 < Base
      def settings_map
        super.concat([
          [:manifestdir, :manifest_dir],
          [:manifest, :manifest],
          [:templatedir, :template_dir],
        ])
      end
    end

    def self.get
      [
        ['4.1', Adapter4X],
        ['4.0', Adapter40],
        ['3.5', Adapter35],
        ['3.4', Adapter34],
        ['3.3', Adapter33],
        ['3.2', Adapter32],
        ['3.0', Adapter30],
        ['2.7', Adapter27]
      ].each do |(version, klass)|
        if Puppet::Util::Package.versioncmp(Puppet.version, version) >= 0
          return klass.new
        end
      end
      raise "Puppet version #{Puppet.version} is not supported."
    end
  end
end
