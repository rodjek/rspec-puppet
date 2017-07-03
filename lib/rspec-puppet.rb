require 'puppet'
require 'rspec'
require 'fileutils'
require 'tmpdir'
require 'rspec-puppet/errors'
require 'rspec-puppet/matchers'
require 'rspec-puppet/example'
require 'rspec-puppet/setup'
require 'rspec-puppet/coverage'
require 'rspec-puppet/adapters'

begin
  require 'puppet/test/test_helper'
rescue LoadError
end

RSpec.configure do |c|
  c.add_setting :enable_pathname_stubbing, :default => false
end

require 'rspec-puppet/monkey_patches'

RSpec.configure do |c|
  c.add_setting :environmentpath, :default => '/etc/puppetlabs/code/environments'
  c.add_setting :module_path, :default => nil
  c.add_setting :manifest_dir, :default => nil
  c.add_setting :manifest, :default => nil
  c.add_setting :template_dir, :default => nil
  c.add_setting :config, :default => nil
  c.add_setting :confdir, :default => '/etc/puppet'
  c.add_setting :default_facts, :default => {}
  c.add_setting :default_node_params, :default => {}
  c.add_setting :default_trusted_facts, :default => {}
  c.add_setting :hiera_config, :default => '/dev/null'
  c.add_setting :parser, :default => 'current'
  c.add_setting :trusted_node_data, :default => false
  c.add_setting :ordering, :default => 'title-hash'
  c.add_setting :stringify_facts, :default => true
  c.add_setting :strict_variables, :default => false
  c.add_setting :adapter
  c.add_setting :setup_fixtures, :default => true

  c.before(:all) do
    if RSpec.configuration.setup_fixtures?
      RSpec::Puppet::Setup.safe_setup_directories(nil, false)
    end
  end

  if defined?(Puppet::Test::TestHelper)
    begin
      Puppet::Test::TestHelper.initialize
    rescue NoMethodError
      Puppet::Test::TestHelper.before_each_test
    end

    c.before :all do
      begin
        Puppet::Test::TestHelper.before_all_tests
      rescue
      end
    end

    c.after :all do
      begin
        Puppet::Test::TestHelper.after_all_tests
      rescue
      end
    end

    c.before :each do
      begin
        Puppet::Test::TestHelper.before_each_test
      rescue Puppet::Context::DuplicateRollbackMarkError
        Puppet::Test::TestHelper.send(:initialize_settings_before_each)
      rescue
      end
    end

    c.after :each do
      begin
        Puppet::Test::TestHelper.after_each_test
      rescue
      end
    end
  end

  c.before :each do
    if self.class.ancestors.include? RSpec::Puppet::Support
      @adapter = RSpec::Puppet::Adapters.get
      @adapter.setup_puppet(self)
      c.adapter = adapter
    end
  end

  c.before :each do |example|
    stub_file_consts(example) if self.respond_to?(:stub_file_consts)
  end
end
