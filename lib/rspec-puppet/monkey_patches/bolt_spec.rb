require 'bolt_spec/plans'

# These changes can be merged into upstream BoltSpec (they look worse than
# really are).
module BoltSpec
  class MockApplicator < Bolt::Applicator
    def apply_ast(raw_ast, targets, options, plan_vars = {})
      ast = Puppet::Pops::Serialization::ToDataConverter.convert(raw_ast, :rich_data => true, :symbol_to_string => true)

      if $future
        plan_vars = Puppet::Pops::Serialization::ToDataConverter.convert(
          plan_vars,
          :rich_data         => true,
          :symbol_as_string  => true,
          :type_by_reference => true,
          :local_reference   => false
        )
        scope = {
          :code_ast     => ast,
          :modulepath   => @modulepath,
          :pdb_config   => @pdb_client.config.to_hash,
          :hiera_config => @hiera_config,
          :plan_vars    => plan_vars,
          :config       => @inventory.config.transport_data_get,
        }
      end

      @executor.log_action('compile catalogues for spec', targets) do
        targets.each do |target|
          cat = if $future
                  future_compile(target, scope)
                else
                  compile(target, ast, plan_vars)
                end
          @executor.store_apply_catalog(target, cat)
        end
      end

      Bolt::ResultSet.new(targets.map { |target| Bolt::ApplyResult.new(target) })
    end
  end

  module Plans
    class MockPuppetDBClient
      attr_reader :config

      def initialize
        @config = Bolt::PuppetDB::Config.new({})
      end
    end

    def run_plan(name, params)
      pal = Bolt::PAL.new(config.modulepath, config.hiera_config, config.boltdir.resource_types)
      applicator = BoltSpec::MockApplicator.new(
        inventory,
        executor,
        pal.modulepath,
        pal.list_modulepath,
        puppetdb_client,
        config.hiera_config,
        4,
      )
      result = pal.run_plan(name, params, executor, inventory, puppetdb_client, applicator)

      if executor.error_message
        raise executor.error_message
      end

      begin
        executor.assert_call_expectations
      rescue StandardError => e
        raise "#{e.message}\nPlan result: #{result}"
      end

      result
    end

    def apply(target)
      executor.apply_catalog(target)
    end

    class MockExecutor
      def store_apply_catalog(target, catalog)
        (@catalogs ||= {})[target.name] = Puppet::Resource::Catalog.from_data_hash(catalog)
      end

      def apply_catalog(target)
        (@catalogs ||= {})[target]
      end
    end
  end
end
