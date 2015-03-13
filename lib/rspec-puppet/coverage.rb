module RSpec::Puppet
  class Coverage

    attr_accessor :filters

    class << self
      extend Forwardable
      def_delegators :instance, :add, :cover!, :report!, :filters, :coveralls!
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
      report[:coverage] = sprintf("%5.2f", ((report[:touched].to_f/report[:total].to_f)*100))

      report[:detailed] = Hash[*@collection.map do |name, wrapper|
        [name, wrapper.to_hash]
      end.flatten]

      puts <<-EOH.gsub(/^ {8}/, '')

        Total resources:   #{report[:total]}
        Touched resources: #{report[:touched]}
        Resource coverage: #{report[:coverage]}%
      EOH

      if report[:coverage] != "100.00"
        puts <<-EOH.gsub(/^ {10}/, '')
          Untouched resources:

          #{
            untouched_resources = report[:detailed].reject do |_,rsrc|
              rsrc["touched"]
            end
            untouched_resources.inject([]) do |memo, (name,_)|
              memo << "  #{name}"
            end.sort.join("\n")
          }
        EOH
      end
    end

    def coveralls!
      require 'coveralls'

      source_files_hash = {}
      source_files = []

      @collection.each do |name, c|
        r = c.resource
        name = r.file
        line = r.line
        if name
          source_files_hash[name] ||= []
          source_files_hash[name][line-1] ||= 0
          source_files_hash[name][line-1] += 1 if c.touched?
        end
      end

      source_files_hash.each do |k, v|
        source_files << {
          :name     => k.gsub(%r{.*/spec/fixtures/modules/[^/]+/}, ''), # hack!
          :source   => File.open(k).read,
          :coverage => v,
        }
      end

      ::Coveralls::API.post_json "jobs", { :source_files => source_files }
      report!
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
