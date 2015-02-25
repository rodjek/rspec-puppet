module RSpec::Puppet
  class Coverage

    attr_accessor :filters

    class << self
      extend Forwardable
      def_delegators(:instance, :add, :cover!, :report!,
                     :filters, :add_filter, :add_from_catalog)
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

    def add_filter(type, title)
      @filters << "#{type.capitalize}[#{title.capitalize}]"
    end

    # add all resources from catalog declared in module test_module
    def add_from_catalog(catalog, test_module)
      catalog.to_a.each do |resource|
        # check filters
        next if @filters.include?(resource.to_s)
        if resource.type == 'Class'
          # if the resource is a class, make sure the class belongs to
          # module test_module
          module_name = resource.title.split('::').first.downcase
          next if module_name != test_module
        elsif resource.file
          # otherwise, the source file should be available, so make
          # sure the manifest declaring the resource is in
          # test_module's directory tree or the site manifest(s)
          paths = Puppet[:modulepath].split(File::PATH_SEPARATOR).map do |dir|
            (Pathname.new(dir) + test_module + 'manifests').to_s
          end
          paths << Puppet[:manifest]
          next unless paths.any? { |path| resource.file.include?(path) }
        end
        add(resource)
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
