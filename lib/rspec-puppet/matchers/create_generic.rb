require 'rspec-puppet/matchers/parameter_matcher'
module RSpec::Puppet
  module ManifestMatchers
    class CreateGeneric
      include RSpec::Puppet::Errors

      def initialize(*args, &block)
        @exp_resource_type = args.shift.to_s.gsub(/^(create|contain)_/, '')
        @args = args
        @block = block
        @referenced_type = referenced_type(@exp_resource_type)
        @title = args[0]

        @errors = []
        @expected_params = []
        @expected_undef_params = []
        @notifies = []
        @subscribes = []
        @requires = []
        @befores = []
      end

      def with(*args, &block)
        params = args.shift
        @expected_params = @expected_params | params.to_a
        self
      end

      def only_with(*args, &block)
        params = args.shift
        @expected_params_count = (@expected_params_count || 0) + params.size
        self.with(params, &block)
      end

      def without(*args, &block)
        params = args.shift
        @expected_undef_params = @expected_undef_params | Array(params)
        self
      end

      def that_notifies(resource)
        @notifies.concat(Array(resource))
        self
      end

      def that_subscribes_to(resource)
        @subscribes.concat(Array(resource))
        self
      end

      def that_requires(resource)
        @requires.concat(Array(resource))
        self
      end

      def that_comes_before(resource)
        @befores.concat(Array(resource))
        self
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^with_/
          param = method.to_s.gsub(/^with_/, '')
          @expected_params << [param, args[0]]
          self
        elsif method.to_s =~ /^only_with_/
          param = method.to_s.gsub(/^only_with_/, '')
          @expected_params_count = (@expected_params_count || 0) + 1
          @expected_params << [param, args[0]]
          self
        elsif method.to_s =~ /^without_/
          param = method.to_s.gsub(/^without_/, '')
          @expected_undef_params << [param, args[0]]
          self
        else
          super
        end
      end

      def matches?(catalogue)
        ret = true
        @catalogue = catalogue.call
        resource = @catalogue.resource(@referenced_type, @title)

        if resource.nil?
          false
        else
          RSpec::Puppet::Coverage.cover!(resource)
          rsrc_hsh = resource.to_hash
          if @expected_params_count
            unless rsrc_hsh.size == @expected_params_count
              ret = false
              (@errors ||= []) << "exactly #{@expected_params_count} parameters but the catalogue contains #{rsrc_hsh.size}"
            end
          end

          check_params(rsrc_hsh, @expected_params, :should) if @expected_params.any?
          check_params(rsrc_hsh, @expected_undef_params, :not) if @expected_undef_params.any?
          check_befores(@catalogue, resource) if @befores.any?
          check_requires(@catalogue, resource) if @requires.any?
          check_notifies(@catalogue, resource) if @notifies.any?
          check_subscribes(@catalogue, resource) if @subscribes.any?

          @errors.empty?
        end
      end

      def failure_message
        "expected that the catalogue would contain #{@referenced_type}[#{@title}]#{errors}"
      end

      def failure_message_when_negated
        "expected that the catalogue would not contain #{@referenced_type}[#{@title}]#{errors}"
      end

      def description
        values = []
        value_str_prefix = "with"

        if @expected_params_count
          values << "exactly #{@expected_params_count} parameters"
        end

        if @expected_params.any?
          values.concat(generate_param_list(@expected_params, :should))
        end

        if @expected_undef_params.any?
          values.concat(generate_param_list(@expected_undef_params, :not))
        end

        if @notifies.any?
          value_str_prefix = "that notifies"
          values = @notifies
        end

        if @subscribes.any?
          value_str_prefix = "that subscribes to"
          values = @subscribes
        end

        if @requires.any?
          value_str_prefix = "that requires"
          values = @requires
        end

        if @befores.any?
          value_str_prefix = "that comes before"
          values = @befores
        end

        unless values.empty?
          if values.length == 1
            value_str = " #{value_str_prefix} #{values.first}"
          else
            value_str = " #{value_str_prefix} #{values[0..-2].join(", ")} and #{values[-1]}"
          end
        end

        "contain #{@referenced_type}[#{@title}]#{value_str}"
      end

      def diffable?
        true
      end

      def expected
        @errors.map {|e| e.expected if e.respond_to?(:expected)}.compact.join("\n\n")
      end

      def actual
        @errors.map {|e| e.actual if e.respond_to?(:actual)}.compact.join("\n\n")
      end

      private
      def referenced_type(type)
        type.split('__').map { |r| r.capitalize }.join('::')
      end

      def errors
        @errors.empty? ? "" : " with #{@errors.join(', and parameter ')}"
      end

      def generate_param_list(list, type)
        output = []
        list.each do |param, value|
          if value.nil?
            output << "#{param.to_s} #{type == :not ? 'un' : ''}defined"
          else
            a = type == :not ? '!' : '='
            b = value.is_a?(Regexp) ? '~' : '>'
            if param.to_s == 'content' and value.is_a?( String )
              output << "#{param.to_s} #{type == :not ? 'not ' : ''} supplied string"
            else
              output << "#{param.to_s} #{a}#{b} #{value.inspect}"
            end
          end
        end
        output
      end

      def check_befores(catalogue, resource)
        @befores.each do |ref|
          unless precedes?(resource, catalogue.resource(ref))
            @errors << BeforeRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_requires(catalogue, resource)
        @requires.each do |ref|
          unless precedes?(catalogue.resource(ref), resource)
            @errors << RequireRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_notifies(catalogue, resource)
        @notifies.each do |ref|
          unless notifies?(resource, catalogue.resource(ref))
            @errors << NotifyRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_subscribes(catalogue, resource)
        @subscribes.each do |ref|
          unless notifies?(catalogue.resource(ref), resource)
            @errors << SubscribeRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def resource_ref(resource)
        resource.respond_to?(:to_ref) ? resource.to_ref : resource
      end

      def resource_from_ref(ref)
        ref.is_a?(Puppet::Resource) ? ref : @catalogue.resource(ref)
      end

      def canonicalize_resource(resource)
        resource_from_ref(resource_ref(resource))
      end

      def canonicalize_resource_ref(ref)
        resource_ref(resource_from_ref(ref))
      end

      def relationship_refs(resource, type)
        resource = canonicalize_resource(resource)
        results = []
        return results unless resource
        Array[resource[type]].flatten.compact.each do |r|
          results << canonicalize_resource_ref(r)
          results << relationship_refs(r, type)
        end

        # Add autorequires if any
        if type == :require and resource.resource_type.respond_to? :eachautorequire
          resource.resource_type.eachautorequire do |t, b|
            Array(resource.to_ral.instance_eval(&b)).each do |dep|
              res = "#{t.to_s.capitalize}[#{dep}]"
              if r = relationship_refs(res, type)
                results << res
                results << r
              end
            end
          end
        end
        results.flatten
      end

      def self_or_upstream(vertex)
        [vertex] + @catalogue.upstream_from_vertex(vertex).keys
      end

      def precedes?(first, second)
        return false if first.nil? || second.nil?

        self_or_upstream(first).each do |u|
          self_or_upstream(second).each do |v|
            before_refs = relationship_refs(u, :before)
            require_refs = relationship_refs(v, :require)

            if before_refs.include?(v.to_ref) || require_refs.include?(u.to_ref) || (before_refs & require_refs).any?
              return true
            end
          end
        end

        # Nothing found
        return false
      end

      def notifies?(first, second)
        return false if first.nil? || second.nil?

        self_or_upstream(first).each do |u|
          self_or_upstream(second).each do |v|
            notify_refs = relationship_refs(u, :notify)
            subscribe_refs = relationship_refs(v, :subscribe)

            if notify_refs.include?(v.to_ref) || subscribe_refs.include?(u.to_ref)
              return true
            end
          end
        end

        # Nothing found
        return false
      end

      # @param resource [Hash<Symbol, Object>] The resource in the catalog
      # @param list [Array<String, Object>] The expected values of the resource
      # @param type [:should, :not] Whether the given parameters should/not match
      def check_params(resource, list, type)
        list.each do |param, value|
          param = param.to_sym

          if value.nil? then
            unless resource[param].nil?
              @errors << "#{param} undefined"
            end
          else
            m = ParameterMatcher.new(param, value, type)
            unless m.matches?(resource)
              @errors.concat m.errors
            end
          end
        end
      end
    end
  end
end
