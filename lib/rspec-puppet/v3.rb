module RSpec::Puppet
  module V3
    def puppet_resource(type, title)
      RSpec::Puppet::V3::Resource.new(type, title)
    end

    class Resource
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
    end
  end
end

# TODO: Limit this to only rspec-puppet example groups
class RSpec::Core::ExampleGroup
  extend RSpec::Puppet::V3
end
