module RSpec::Puppet
  module ManifestMatchers
    class CountGeneric
      def initialize(type, count, *method)
        @type = if type.nil?
                  method[0].to_s.gsub(%r{^have_(.+)_resource_count$}, '\1')
                else
                  type
                end
        @referenced_type = referenced_type(@type)
        @expected_number = count.to_i
      end

      def matches?(catalogue)
        @catalogue = catalogue.call

        if @type == 'resource'
          @actual_number = @catalogue.resources.count do |res|
            !(%w[Class Node].include? res.type)
          end

          # Puppet automatically adds Stage[main]
          @actual_number -= 1
        else
          @actual_number = @catalogue.resources.count do |res|
            res.type == @referenced_type
          end

          # Puppet automatically adds Class[main] and Class[Settings]
          @actual_number -= 2 if @type == 'class'
        end

        @actual_number == @expected_number
      end

      def description
        desc = []

        desc << "contain exactly #{@expected_number}"
        if @type == 'class'
          desc << @expected_number == 1 ? 'class' : 'classes'
        else
          desc << @referenced_type.to_s unless @type == 'resource'
          desc << @expected_number == 1 ? 'resource' : 'resources'
        end

        desc.join(' ')
      end

      def failure_message
        'expected that the catalogue would ' + description + ' but it contains #{@actual_number}'
      end

      def failure_message_when_negated
        'expected that the catalogue would not ' + description + ' but it does'
      end

      private

      def referenced_type(type)
        type.split('__').map(&:capitalize).join('::')
      end
    end

    # rubocop:disable Style/PredicateName
    def have_class_count(count)
      RSpec::Puppet::ManifestMatchers::CountGeneric.new('class', count)
    end

    def have_resource_count(count)
      RSpec::Puppet::ManifestMatchers::CountGeneric.new('resource', count)
    end
    # rubocop:enable Style/PredicateName
  end
end
