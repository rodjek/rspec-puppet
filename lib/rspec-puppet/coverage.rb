module RSpec::Puppet
  class Coverage

    attr_accessor :filters

    class << self
      extend Forwardable
      def_delegators :instance, :add, :cover!, :report!, :filters
    end

    include Singleton

    def initialize
      @collection = {}
      @filters = ['Stage[main]', 'Class[Settings]', 'Class[main]']
    end

    def add(resource)
      if !exists?(resource) && !filtered?(resource)
        @collection[resource.to_s] = ResourceWrapper.new(resource)
      end
    end

    def filtered?(resource)
      filters.include?(resource.to_s)
    end

    def cover!(resource)
      if !filtered?(resource) && (wrapper = find(resource))
        wrapper.touch!
      end
    end

    def report!
      report = {}

      report[:total] = @collection.size
      report[:touched] = @collection.count { |_, resource| resource.touched? }
      report[:untouched] = report[:total] - report[:touched]
      report[:coverage] = ((report[:touched].to_f/report[:total].to_f)*100).round(2)

      report[:detailed] = Hash[*@collection.map do |name, wrapper|
        [name, wrapper.to_hash]
      end.flatten]

      puts <<-EOH.gsub(/^ {8}/, '')

        Total resources:   #{report[:total]}
        Touched resources: #{report[:touched]}
        Resource coverage: #{report[:coverage]}%

        Untouched resources:

        #{
          report[:detailed].select { |_, resource| !resource[:touch]}.map do |name, resource|
            "  #{name}"
          end.flatten.join("\n")
        }
      EOH
    end

    private

      def find(resource)
        @collection[resource.to_s]
      end

      def exists?(resource)
        !find(resource).nil?
      end

      class ResourceWrapper
        attr_reader :resource

        def initialize(resource = nil)
          @resource = resource
        end

        def to_s
          @resource.to_s
        end

        def to_hash
          {
            'touched' => touched?,
          }
        end

        def touch!
          @touched = true
        end

        def touched?
          !!@touched
        end
      end

  end
end
