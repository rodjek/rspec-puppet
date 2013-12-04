require 'puppet'
require 'rspec'
require 'fileutils'
require 'tmpdir'
require 'rspec-puppet/errors'
require 'rspec-puppet/matchers'
require 'rspec-puppet/example'
require 'rspec-puppet/setup'

begin
  require 'puppet/test/test_helper'
rescue LoadError
end

RSpec.configure do |c|
  c.add_setting :module_path, :default => '/etc/puppet/modules'
  c.add_setting :manifest_dir, :default => nil
  c.add_setting :manifest, :default => nil
  c.add_setting :template_dir, :default => nil
  c.add_setting :config, :default => nil
  c.add_setting :confdir, :default => '/etc/puppet'
  c.add_setting :default_facts, :default => {}
  c.add_setting :hiera_config, :default => nil

  if defined?(Puppet::Test::TestHelper)
    begin
      Puppet::Test::TestHelper.initialize
    rescue NoMethodError
      Puppet::Test::TestHelper.before_each_test
    end

    c.before :all do
      Puppet::Test::TestHelper.before_all_tests
    end

    c.after :all do
      Puppet::Test::TestHelper.after_all_tests
    end

    c.before :each do
      Puppet::Test::TestHelper.before_each_test
    end

    c.after :each do
      Puppet::Test::TestHelper.after_each_test
    end
  end
end
