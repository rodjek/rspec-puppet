module RSpec::Puppet
  module Adapters

    class Base
      # Set up all Puppet settings applicable for this Puppet version
      #
      # @param example_group [RSpec::Core::ExampleGroup] The RSpec context to use for local settings
      # @return [void]
      def setup_puppet(example_group)
        settings_map.each do |puppet_setting, rspec_setting|
          set_setting(example_group, puppet_setting, rspec_setting)
        end
      end

      # Set up a specific Puppet setting.
      # configuration setting.
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
      # @param puppet_setting [Symbol] The name of the Puppet setting to configure
      # @param rspec_setting [Symbol] The name of the RSpec context specific or global setting to use
      # @return [void]
      def set_setting(example_group, puppet_setting, rspec_setting)
        if example_group.respond_to?(rspec_setting)
          value = example_group.send(rspec_setting)
        else
          value = RSpec.configuration.send(rspec_setting)
        end
        begin
          Puppet[puppet_setting] = value
        rescue ArgumentError
          # TODO: this silently swallows errors when applying settings that the current
          # Puppet version does not accept, which means that user specified settings
          # are ignored. This may lead to suprising behavior for users.
        end
      end

      def catalog(node, _)
        Puppet::Resource::Catalog.indirection.find(node.name, :use_node => node)
      end

      def environment(name)
        Puppet::Node::Environment.new(name)
      end

      def settings_map
        [
          [:modulepath, :module_path],
          [:config, :config],
          [:confdir, :confdir],
        ]
      end
    end

    class Adapter4X < Base
      def settings_map
        super.concat([
          [:environmentpath, :environmentpath],
          [:hiera_config, :hiera_config],
          [:strict_variables, :strict_variables],
        ])
      end

      def catalog(node, environment_name)
        env = environment(environment_name)
        loader = Puppet::Environments::Static.new(env)
        Puppet.override({:environments => loader}, 'Setup test environment') do
          node.environment = env
          super
        end
      end

      def environment(name)
        modulepath = RSpec.configuration.module_path || File.join(Puppet[:environmentpath], 'fixtures', 'modules')
        manifest = RSpec.configuration.manifest || File.join(Puppet[:environmentpath], 'fixtures', 'manifests')
        Puppet::Node::Environment.create(name, [modulepath], manifest)
      end
    end

    class Adapter3X < Base
      def settings_map
        super.concat([
          [:manifestdir, :manifest_dir],
          [:manifest, :manifest],
          [:templatedir, :template_dir],
          [:hiera_config, :hiera_config],
          [:parser, :parser],
          [:trusted_node_data, :trusted_node_data],
          [:ordering, :ordering],
          [:stringify_facts, :stringify_facts],
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
        [4.0, Adapter4X],
        [3.0, Adapter3X],
        [2.7, Adapter27]
      ].each do |(version, klass)|
        if Puppet.version.to_f >= version
          return klass.new
        end
      end
      raise "Puppet version #{Puppet.version.to_f} is not supported."
    end
  end
end
