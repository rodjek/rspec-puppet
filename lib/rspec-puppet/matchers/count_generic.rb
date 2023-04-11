# frozen_string_literal: true

module RSpec::Puppet
  module ManifestMatchers
    class CountGeneric
      DEFAULT_RESOURCES = [
        'Class[main]',
        'Class[Settings]',
        'Stage[main]'
      ].freeze

      attr_reader :resource_type

      def initialize(type, count, *method)
        @type = if type.nil?
                  method[0].to_s.gsub(/^have_(.+)_resource_count$/, '\1')
                else
                  type
                end
        @resource_type = referenced_type(@type)
        @expected_number = count.to_i
      end

      def matches?(catalogue)
        @catalogue = catalogue.call

        resources = @catalogue.resources.reject do |res|
          DEFAULT_RESOURCES.include?(res.ref)
        end

        @actual_number = if @type == 'resource'
                           resources.count do |res|
                             !%w[Class Node].include?(res.type)
                           end
                         else
                           resources.count do |res|
                             res.type == @resource_type
                           end
                         end

        @actual_number == @expected_number
      end

      def description
        desc = []

        desc << "contain exactly #{@expected_number}"
        if @type == 'class'
          desc << (@expected_number == 1 ? 'class' : 'classes').to_s
        else
          desc << @resource_type.to_s unless @type == 'resource'
          desc << (@expected_number == 1 ? 'resource' : 'resources').to_s
        end

        desc.join(' ')
      end

      def failure_message
        "expected that the catalogue would #{description} but it contains #{@actual_number}"
      end

      def failure_message_when_negated
        "expected that the catalogue would not #{description} but it does"
      end

      def supports_block_expectations
        true
      end

      def supports_value_expectations
        true
      end

      private

      def referenced_type(type)
        type.split('__').map(&:capitalize).join('::')
      end
    end

    def have_class_count(count)
      RSpec::Puppet::ManifestMatchers::CountGeneric.new('class', count)
    end

    def have_resource_count(count)
      RSpec::Puppet::ManifestMatchers::CountGeneric.new('resource', count)
    end
  end
end
