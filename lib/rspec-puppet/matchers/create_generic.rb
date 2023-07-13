# frozen_string_literal: true

require 'set'
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

      def with(*args)
        params = args.shift
        @expected_params |= params.to_a
        self
      end

      def only_with(*args, &block)
        params = args.shift
        @expected_params_count = (@expected_params_count || 0) + params.compact.size
        with(params, &block)
      end

      def without(*args)
        params = args.shift
        @expected_undef_params |= Array(params)
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
        case method.to_s
        when /^with_/
          param = method.to_s.gsub(/^with_/, '')
          @expected_params << [param, args[0]]
          self
        when /^only_with_/
          param = method.to_s.gsub(/^only_with_/, '')
          @expected_params_count = (@expected_params_count || 0) + 1
          @expected_params << [param, args[0]]
          self
        when /^without_/
          param = method.to_s.gsub(/^without_/, '')
          @expected_undef_params << [param, args[0]]
          self
        else
          super
        end
      end

      def matches?(catalogue)
        ret = true
        @catalogue = catalogue.is_a?(Puppet::Resource::Catalog) ? catalogue : catalogue.call
        resource = @catalogue.resource(@referenced_type, @title)

        if resource.nil?
          false
        else
          RSpec::Puppet::Coverage.cover!(resource)
          rsrc_hsh = resource.to_hash
          if resource.respond_to?(:sensitive_parameters)
            resource.sensitive_parameters.each do |s_param|
              rsrc_hsh[s_param] = ::Puppet::Pops::Types::PSensitiveType::Sensitive.new(rsrc_hsh[s_param])
            end
          end

          namevar = if resource.builtin_type?
                      resource.resource_type.key_attributes.first.to_s
                    else
                      'name'
                    end

          if @expected_params.none? { |param| param.first.to_s == namevar } && rsrc_hsh.key?(namevar.to_sym)
            rsrc_hsh.delete(namevar.to_sym)
          end

          if @expected_params_count && rsrc_hsh.size != @expected_params_count
            ret = false
            (@errors ||= []) << "exactly #{@expected_params_count} parameters but the catalogue contains #{rsrc_hsh.size}"
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
        value_str_prefix = 'with'

        values << "exactly #{@expected_params_count} parameters" if @expected_params_count

        values.concat(generate_param_list(@expected_params, :should)) if @expected_params.any?

        values.concat(generate_param_list(@expected_undef_params, :not)) if @expected_undef_params.any?

        if @notifies.any?
          value_str_prefix = 'that notifies'
          values = @notifies
        end

        if @subscribes.any?
          value_str_prefix = 'that subscribes to'
          values = @subscribes
        end

        if @requires.any?
          value_str_prefix = 'that requires'
          values = @requires
        end

        if @befores.any?
          value_str_prefix = 'that comes before'
          values = @befores
        end

        unless values.empty?
          value_str = if values.length == 1
                        " #{value_str_prefix} #{values.first}"
                      else
                        " #{value_str_prefix} #{values[0..-2].join(', ')} and #{values[-1]}"
                      end
        end

        "contain #{@referenced_type}[#{@title}]#{value_str}"
      end

      def diffable?
        true
      end

      def supports_block_expectations
        true
      end

      def supports_value_expectations
        true
      end

      def expected
        @errors.filter_map { |e| e.expected if e.respond_to?(:expected) }.join("\n\n")
      end

      def actual
        @errors.filter_map { |e| e.actual if e.respond_to?(:actual) }.join("\n\n")
      end

      private

      def referenced_type(type)
        type.split('__').map(&:capitalize).join('::')
      end

      def errors
        @errors.empty? ? '' : " with #{@errors.join(', and parameter ')}"
      end

      def generate_param_list(list, type)
        output = []
        list.each do |param, value|
          if value.nil?
            output << "#{param} #{type == :not ? 'un' : ''}defined"
          else
            a = type == :not ? '!' : '='
            b = value.is_a?(Regexp) ? '~' : '>'
            output << if (param.to_s == 'content') && value.is_a?(String)
                        "#{param} #{type == :not ? 'not ' : ''} supplied string"
                      else
                        "#{param} #{a}#{b} #{value.inspect}"
                      end
          end
        end
        output
      end

      def check_befores(_catalogue, resource)
        @befores.each do |ref|
          unless precedes?(resource, canonicalize_resource(ref))
            @errors << BeforeRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_requires(_catalogue, resource)
        @requires.each do |ref|
          unless precedes?(canonicalize_resource(ref), resource)
            @errors << RequireRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_notifies(_catalogue, resource)
        @notifies.each do |ref|
          unless notifies?(resource, canonicalize_resource(ref))
            @errors << NotifyRelationshipError.new(resource.to_ref, ref)
          end
        end
      end

      def check_subscribes(_catalogue, resource)
        @subscribes.each do |ref|
          unless notifies?(canonicalize_resource(ref), resource)
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
        res = resource_from_ref(resource_ref(resource))
        if res.nil?
          resource = Struct.new(:type, :title).new(*@catalogue.title_key_for_ref(resource)) if resource.is_a?(String)
          res = @catalogue.resource_keys.select do |type, _name|
            type == resource.type
          end.filter_map do |type, name|
            @catalogue.resource(type, name)
          end.find do |cat_res|
            cat_res.builtin_type? && cat_res.uniqueness_key.first == resource.title
          end
        end
        res
      end

      def canonicalize_resource_ref(ref)
        resource_ref(resource_from_ref(ref))
      end

      def relationship_refs(resource, type, visited = Set.new)
        resource = canonicalize_resource(resource)
        results = Set.new
        return results unless resource

        # guard to prevent infinite recursion
        return [canonicalize_resource_ref(resource)] if visited.include?(resource.object_id)

        visited << resource.object_id

        [resource[type]].flatten.compact.each do |r|
          results << canonicalize_resource_ref(r)
          results << relationship_refs(r, type, visited)

          res = canonicalize_resource(r)
          if res&.builtin_type?
            results << res.to_ref
            results << "#{res.type.to_s.capitalize}[#{res.uniqueness_key.first}]"
          end
        end

        # Add auto* (autorequire etc) if any
        if %i[before notify require subscribe].include?(type)
          func = "eachauto#{type}".to_sym
          if resource.resource_type.respond_to?(func)
            resource.resource_type.send(func) do |t, b|
              Array(resource.to_ral.instance_eval(&b)).each do |dep|
                next if dep.nil?

                res = "#{t.to_s.capitalize}[#{dep}]"
                if (r = relationship_refs(res, type, visited))
                  results << res
                  results << r
                end
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
            before_refs = relationship_refs(u, :before) + relationship_refs(u, :notify)
            require_refs = relationship_refs(v, :require) + relationship_refs(u, :subscribe)

            if before_refs.include?(v.to_ref) || require_refs.include?(u.to_ref) || (before_refs & require_refs).any?
              return true
            end
          end
        end

        # Nothing found
        false
      end

      def notifies?(first, second)
        return false if first.nil? || second.nil?

        self_or_upstream(first).each do |u|
          self_or_upstream(second).each do |v|
            notify_refs = relationship_refs(u, :notify)
            subscribe_refs = relationship_refs(v, :subscribe)

            return true if notify_refs.include?(v.to_ref) || subscribe_refs.include?(u.to_ref)
          end
        end

        # Nothing found
        false
      end

      # @param resource [Hash<Symbol, Object>] The resource in the catalog
      # @param list [Array<String, Object>] The expected values of the resource
      # @param type [:should, :not] Whether the given parameters should/not match
      def check_params(resource, list, type)
        list.each do |param, value|
          param = param.to_sym

          if value.nil?
            @errors << "#{param} undefined but it is set to #{resource[param].inspect}" unless resource[param].nil?
          else
            m = ParameterMatcher.new(param, value, type)
            @errors.concat m.errors unless m.matches?(resource)
          end
        end
      end
    end
  end
end
