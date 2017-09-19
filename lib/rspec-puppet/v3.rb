module RSpec::Puppet
  module V3
    def puppet_resource(type, title)
      RSpec::Puppet::V3::Resource.new(type, title)
    end

    class Resource
      include RSpec::Puppet::Helpers::Relationships

      def initialize(type, title)
        @type = type
        @title = title
      end

      def to_s
        "#{@type.capitalize}[#{@title}]"
      end
      alias_method :inspect, :to_s

      def catalogue
        @catalogue ||= RSpec.current_example.example_group_instance.catalogue
      end

      def catalogue_resource
        @catalogue_resource ||= catalogue.resource(@type, @title)
      end

      def parameters
        exist? ? catalogue_resource.to_hash : {}
      end
      alias_method :params, :parameters

      def exist?
        RSpec::Puppet::Coverage.cover!(catalogue_resource)
        !catalogue_resource.nil?
      end
      alias_method :in_catalogue?, :exist?
      alias_method :in_catalog?, :exist?

      def sanitise_resource(resource)
        if resource.is_a?(self.class)
          resource.catalogue_resource
        else
          canonicalize_resource(resource)
        end
      end

      def notifies_resource?(other_resource)
        return false unless exist?
        other_resource = sanitise_resource(other_resource)
        return false if other_resource.nil?

        notifies?(catalogue_resource, other_resource)
      end

      def subscribes_to_resource?(other_resource)
        return false unless exist?
        other_resource = sanitise_resource(other_resource)
        return false if other_resource.nil?

        notifies?(other_resource, catalogue_resource)
      end

      def requires_resource?(other_resource)
        return false unless exist?
        other_resource = sanitise_resource(other_resource)
        return false if other_resource.nil?

        precedes?(other_resource, catalogue_resource)
      end

      def comes_before_resource?(other_resource)
        return false unless exist?
        other_resource = sanitise_resource(other_resource)
        return false if other_resource.nil?

        precedes?(catalogue_resource, other_resource)
      end
    end
  end
end

# TODO: Limit this to only rspec-puppet example groups
class RSpec::Core::ExampleGroup
  extend RSpec::Puppet::V3
  include RSpec::Puppet::V3
end
