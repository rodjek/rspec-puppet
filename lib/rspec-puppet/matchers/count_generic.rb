module RSpec::Puppet
  module ManifestMatchers
    class CountGeneric
      def initialize(type, count, *method)
        if type.nil?
          @type = method.to_s.gsub(/^have_(.+)_resource_count$/, '\1')
        else
          @type = type
        end
        @referenced_type = referenced_type(@type)
        @expected_number = count.to_i
      end

      def matches?(catalogue)
        ret = true

        case @type
        when "class"
          actual = catalogue.resources.select do |res|
            res.type.eql? "Class"
          end

          # Puppet automatically adds Class[main] and Class[Settings]
          @actual_number = actual.length - 2
        when "resource"
          actual = catalogue.resources.select do |res|
            !res.type.eql? "Class" and !res.type.eql? "Node"
          end

          # Puppet automatically adds Stage[main]
          @actual_number = actual.length - 1
        else
          actual = catalogue.resources.select do |res|
            res.type.eql? "#{@referenced_type}"
          end

          @actual_number = actual.length
        end

        unless @actual_number == @expected_number
          ret = false
        end

        ret
      end

      def description
        desc = []

        desc << "contain exactly #{@expected_number}"
        if @type == "class"
          desc << "#{@expected_number == 1 ? "class" : "classes" }"
        else
          unless @type == "resource"
            desc << "#{@referenced_type}"
          end
          desc << "#{@expected_number == 1 ? "resource" : "resources" }"
        end

        desc.join(" ")
      end

      def failure_message_for_should
        "expected that the catalogue would " + description + " but it contains #{@actual_number}"
      end

      def failure_message_for_should_not
        "expected that the catalogue would not " + description + " but it does"
      end

    private

      def referenced_type(type)
        type.split('__').map { |r| r.capitalize }.join('::')
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
