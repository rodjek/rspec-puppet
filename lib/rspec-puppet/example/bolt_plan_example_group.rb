module RSpec::Puppet
  module BoltPlanExampleGroup
    def self.included(mod)
      begin
        require 'bolt_spec/plans'
        require 'rspec-puppet/monkey_patches/bolt_spec'
        mod.include BoltSpec::Plans
      rescue LoadError
        mod.metadata[:skip] = 'bolt not available'
      end

      mod.before(:context) do
        BoltSpec::Plans.init
      end

      mod.let(:params) do
        {}
      end

      mod.subject(:result) do
        run_plan(self.class.top_level_description, params)
      end
    end

    def rspec_puppet_cleanup
      Puppet[:tasks] = false
    end
  end
end
