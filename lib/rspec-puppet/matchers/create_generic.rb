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
        @notifies << resource
        self
      end

      def that_subscribes_to(resource)
        @subscribes << resource
        self
      end

      def that_requires(resource)
        @requires << resource
        self
      end

      def that_comes_before(resource)
        @befores << resource
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
        resource = catalogue.resource(@referenced_type, @title)

        if resource.nil?
          false
        else
          rsrc_hsh = resource.to_hash
          if @expected_params_count
            unless rsrc_hsh.size == @expected_params_count
              ret = false
              (@errors ||= []) << "exactly #{@expected_params_count} parameters but the catalogue contains #{rsrc_hsh.size}"
            end
          end

          check_params(rsrc_hsh, @expected_params, :should) if @expected_params.any?
          check_params(rsrc_hsh, @expected_undef_params, :not) if @expected_undef_params.any?
          check_befores(catalogue, resource) if @befores.any?
          check_requires(catalogue, resource) if @requires.any?
          check_notifies(catalogue, resource) if @notifies.any?
          check_subscribes(catalogue, resource) if @subscribes.any?

          @errors.empty?
        end
      end

      def failure_message_for_should
        "expected that the catalogue would contain #{@referenced_type}[#{@title}]#{errors}"
      end

      def failure_message_for_should_not
        "expected that the catalogue would not contain #{@referenced_type}[#{@title}]#{errors}"
      end

      def description
        values = []

        if @expected_params_count
          values << "exactly #{@expected_params_count} parameters"
        end

        if @expected_params.any?
          values.concat(generate_param_list(@expected_params, :should))
        end

        if @expected_undef_params.any?
          values.concat(generate_param_list(@expected_undef_params, :not))
        end

        unless values.empty?
          if values.length == 1
            value_str = " with #{values.first}"
          else
            value_str = " with #{values[0..-2].join(", ")} and #{values[-1]}"
          end
        end

        "contain #{@referenced_type}[#{@title}]#{value_str}"
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
            output << "#{param.to_s} #{a}#{b} #{value.inspect}"
          end
        end
        output
      end

      def check_befores(catalogue, resource)
        before_refs = Array[resource[:before]].flatten.map { |ref|
          ref.respond_to?(:to_ref) ? ref.to_ref : ref
        }

        @befores.each do |ref|
          unless before_refs.include?(ref)
            required_refs = Array[catalogue.resource(ref)[:require]].flatten.map { |r|
              r.respond_to?(:to_ref) ? r.to_ref : r
            }
            unless required_refs.include?(resource.to_ref)
              @errors << BeforeRelationshipError.new(resource.to_ref, ref)
            end
          end
        end
      end

      def check_requires(catalogue, resource)
        require_refs = Array[resource[:require]].flatten.map { |ref|
          ref.respond_to?(:to_ref) ? ref.to_ref : ref
        }

        @requires.each do |ref|
          unless require_refs.include?(ref)
            before_refs = Array[catalogue.resource(ref)[:before]].flatten.map { |r|
              r.respond_to?(:to_ref) ? r.to_ref : r
            }
            unless before_refs.include?(resource.to_ref)
              @errors << RequireRelationshipError.new(resource.to_ref, ref)
            end
          end
        end
      end

      def check_notifies(catalogue, resource)
        notify_refs = Array[resource[:notify]].flatten.map { |ref|
          ref.respond_to?(:to_ref) ? ref.to_ref : ref
        }

        @notifies.each do |ref|
          unless notify_refs.include?(ref)
            subscribed_refs = Array[catalogue.resource(ref)[:subscribe]].flatten.map { |r|
              r.respond_to?(:to_ref) ? r.to_ref : r
            }
            unless subscribed_refs.include?(resource.to_ref)
              @errors << NotifyRelationshipError.new(resource.to_ref, ref)
            end
          end
        end
      end

      def check_subscribes(catalogue, resource)
        subscribed_refs = Array[resource[:subscribe]].flatten.map { |ref|
          ref.respond_to?(:to_ref) ? ref.to_ref : ref
        }

        @subscribes.each do |ref|
          unless subscribed_refs.include?(ref)
            notify_refs = Array[catalogue.resource(ref)[:notify]].flatten.map { |r|
              r.respond_to?(:to_ref) ? r.to_ref : r
            }
            unless notify_refs.include?(resource.to_ref)
              @errors << SubscribeRelationshipError.new(resource.ref, ref)
            end
          end
        end
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
