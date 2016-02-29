begin
  require 'puppet/indirector/catalog/compiler'
rescue LoadError
end

# Try to defend against changes in future versions of puppet by checking the
# class we are patching still exists
if defined?(Puppet::Resource::Catalog::Compiler)
  # Define a method on an object instance
  def define_method_on(obj, method, &block)
    if obj.respond_to? :define_singleton_method
      obj.define_singleton_method(method, &block)
    else
      # Support for ruby 1.8
      obj.instance_eval do
        class << self
          self
        end.send(:define_method, method, &block)
      end
    end
  end

  # Add __rspec_puppet_exported_resources accessor to every compiled catalog
  # by patching the puppet compiler class
  class Puppet::Resource::Catalog::Compiler
    alias_method :filter_exclude_exported_resources, :filter
    def filter(catalog)
      filter_exclude_exported_resources(catalog).tap do |filtered|
        # Every time a catalog is filtered to exclude exported resources, add
        # a .__rspec_puppet_exported_resources accessor which exposes the
        # resources which would have been filtered out.
        define_method_on(filtered, :__rspec_puppet_exported_resources) do
          catalog.filter { |r| !r.exported? }
        end
      end
    end
  end
end

# Expose a catalogue's exported resources to tests
module RSpec::Puppet
  module Support
    def exported_resources
      lambda do
        if catalogue.respond_to? :__rspec_puppet_exported_resources
          catalogue.__rspec_puppet_exported_resources
        else
          fail 'Exported resources are not supported on this version of puppet'
        end
      end
    end
  end
end
