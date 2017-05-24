require 'rspec-puppet/support'
require 'rspec-puppet/example/define_example_group'
require 'rspec-puppet/example/class_example_group'
require 'rspec-puppet/example/function_example_group'
require 'rspec-puppet/example/host_example_group'
require 'rspec-puppet/example/type_example_group'
require 'rspec-puppet/example/type_alias_example_group'
require 'rspec-puppet/example/provider_example_group'
require 'rspec-puppet/example/application_example_group'

RSpec::configure do |c|

  def c.rspec_puppet_include(group, type, file_path)
    escaped_file_path = Regexp.compile(file_path.join('[\\\/]'))
    if RSpec::Version::STRING < '3'
      self.include group, :type => type, :example_group => { :file_path => escaped_file_path }, :spec_type => type
    else
      self.include group, :type => type, :file_path => lambda { |file_path, metadata| metadata[:type].nil? && escaped_file_path =~ file_path }
    end
  end

  c.rspec_puppet_include RSpec::Puppet::DefineExampleGroup, :define, %w[spec defines]
  c.rspec_puppet_include RSpec::Puppet::ClassExampleGroup, :class, %w[spec classes]
  c.rspec_puppet_include RSpec::Puppet::FunctionExampleGroup, :puppet_function, %w[spec functions]
  c.rspec_puppet_include RSpec::Puppet::HostExampleGroup, :host, %w[spec hosts]
  c.rspec_puppet_include RSpec::Puppet::TypeExampleGroup, :type, %w[spec types]
  c.rspec_puppet_include RSpec::Puppet::TypeAliasExampleGroup, :type_alias, %w[spec type_aliases]
  c.rspec_puppet_include RSpec::Puppet::ProviderExampleGroup, :provider, %w[spec providers]
  c.rspec_puppet_include RSpec::Puppet::ApplicationExampleGroup, :application, %w[spec applications]

  # Hook for each example group type to remove any caches or instance variables, since they will remain
  # and cause a memory leak.  Can't be assigned per type by :file_path, so check for its presence.
  c.after(:each) { rspec_puppet_cleanup if respond_to?(:rspec_puppet_cleanup) }
end
