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

      def check_params(resource, list, type)
        list.each do |param, value|
          param = param.to_sym

          if value.nil? then
            unless resource[param].nil?
              @errors << "#{param} undefined"
            end
          elsif value.is_a? Regexp
            check_regexp_param(type, resource, param, value)
          elsif value.is_a? Array
            check_array_param(type, resource, param, value)
          elsif value.is_a? Proc
            check_proc_param(type, resource, param, value)
          else
            check_string_param(type, resource, param, value)
          end
        end
      end

      def check_regexp_param(type, resource, param, value)
        if !!(resource[param].to_s =~ value) == (type == :not)
          @errors << RegexpMatchError.new(param, value, resource[param], type == :not)
        end
      end

      def check_array_param(type, resource, param, value)
        op = type == :not ? :"!=" : :"=="
        unless Array(resource[param]).flatten.join.send(op, value.flatten.join)
          @errors << MatchError.new(param, value, resource[param], type == :not)
        end
      end

      def check_proc_param(type, resource, param, value)
        expected_return = type == :not ? false : true
        actual_return = value.call(resource[param].to_s)
        if actual_return != expected_return
          @errors << ProcMatchError.new(param, expected_return, actual_return, type == :not)
        end
      end

      def check_string_param(type, resource, param, value)
        if (resource[param].to_s == value.to_s) == (type == :not)
          @errors << MatchError.new(param, value, resource[param], (type == :not))
        end
      end
    end
  end
end
