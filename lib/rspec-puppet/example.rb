require 'rspec-puppet/support'
require 'rspec-puppet/example/define_example_group'
require 'rspec-puppet/example/class_example_group'
require 'rspec-puppet/example/function_example_group'
require 'rspec-puppet/example/host_example_group'
require 'rspec-puppet/example/type_example_group'
require 'rspec-puppet/example/provider_example_group'
require 'rspec-puppet/example/application_example_group'

RSpec::configure do |c|

  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]'))
  end

  if RSpec::Version::STRING < '3'
    c.include RSpec::Puppet::DefineExampleGroup, :type => :define, :example_group => {
      :file_path => c.escaped_path(%w[spec defines])
    }
    c.include RSpec::Puppet::ClassExampleGroup, :type => :class, :example_group => {
      :file_path => c.escaped_path(%w[spec classes])
    }
    c.include RSpec::Puppet::FunctionExampleGroup, :type => :puppet_function, :example_group => {
      :file_path => c.escaped_path(%w[spec functions])
    }
    c.include RSpec::Puppet::HostExampleGroup, :type => :host, :example_group => {
      :file_path => c.escaped_path(%w[spec hosts])
    }
    c.include RSpec::Puppet::TypeExampleGroup, :type => :type, :example_group => {
      :file_path => c.escaped_path(%w[spec types])
    }
    c.include RSpec::Puppet::ProviderExampleGroup, :type => :provider, :example_group => {
      :file_path => c.escaped_path(%w[spec providers])
    }
    c.include RSpec::Puppet::ApplicationExampleGroup, :type => :application, :example_group => {
      :file_path => c.escaped_path(%w[spec applications])
    }
  else
    c.include RSpec::Puppet::DefineExampleGroup, :type => :define, :file_path => c.escaped_path(%w[spec defines])
    c.include RSpec::Puppet::ClassExampleGroup, :type => :class, :file_path => c.escaped_path(%w[spec classes])
    c.include RSpec::Puppet::FunctionExampleGroup, :type => :puppet_function, :file_path => c.escaped_path(%w[spec functions])
    c.include RSpec::Puppet::HostExampleGroup, :type => :host, :file_path => c.escaped_path(%w[spec hosts])
    c.include RSpec::Puppet::TypeExampleGroup, :type => :type, :file_path => c.escaped_path(%w[spec types])
    c.include RSpec::Puppet::ProviderExampleGroup, :type => :provider, :file_path => c.escaped_path(%w[spec providers])
    c.include RSpec::Puppet::ApplicationExampleGroup, :type => :application, :file_path => c.escaped_path(%w[spec applications])
  end

  # Hook for each example group type to remove any caches or instance variables, since they will remain
  # and cause a memory leak.  Can't be assigned per type by :file_path, so check for its presence.
  c.after(:each) { rspec_puppet_cleanup if respond_to?(:rspec_puppet_cleanup) }
end
