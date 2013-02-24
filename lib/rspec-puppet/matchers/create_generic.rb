module RSpec::Puppet
  module ManifestMatchers
    class CreateGeneric
      def initialize(*args, &block)
        @exp_resource_type = args.shift.to_s.gsub(/^(create|contain)_/, '')
        @args = args
        @block = block
        @referenced_type = referenced_type(@exp_resource_type)
        @title = args[0]
      end

      def with(*args, &block)
        params = args.shift
        @expected_params = (@expected_params || []) | params.to_a
        self
      end

      def only_with(*args, &block)
        params = args.shift
        @expected_params_count = (@expected_params_count || 0) + params.size
        self.with(params, &block)
      end

      def without(*args, &block)
        params = args.shift
        @expected_undef_params = (@expected_undef_params || []) | Array(params)
        self
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^with_/
          param = method.to_s.gsub(/^with_/, '')
          (@expected_params ||= []) << [param, args[0]]
          self
        elsif method.to_s =~ /^only_with_/
          param = method.to_s.gsub(/^only_with_/, '')
          @expected_params_count = (@expected_params_count || 0) + 1
          (@expected_params ||= []) << [param, args[0]]
          self
        elsif method.to_s =~ /^without_/
          param = method.to_s.gsub(/^without_/, '')
          (@expected_undef_params ||= []) << [param, args[0]]
          self
        else
          super
        end
      end

      def matches?(catalogue)
        ret = true
        resource = catalogue.resource(@referenced_type, @title)

        if resource.nil?
          ret = false
        else
          rsrc_hsh = resource.to_hash
          if @expected_params_count
            unless rsrc_hsh.size == @expected_params_count
              ret = false
              (@errors ||= []) << "exactly #{@expected_params_count} parameters but the catalogue contains #{rsrc_hsh.size}"
            end
          end
          if @expected_params
            @expected_params.each do |name, value|
              if value.kind_of?(Regexp) then
                unless rsrc_hsh[name.to_sym].to_s =~ value
                  ret = false
                  (@errors ||= []) << "#{name.to_s} matching `#{value.inspect}` but its value of `#{rsrc_hsh[name.to_sym].inspect}` does not"
                end
              elsif value.kind_of?(Array) then
                unless Array(rsrc_hsh[name.to_sym]).flatten.join == value.flatten.join
                  ret = false
                  (@errors ||= []) << "#{name.to_s} set to `#{value.inspect}` but it is set to `#{rsrc_hsh[name.to_sym].inspect}` in the catalogue"
                end
              elsif value.kind_of?(Proc) then
                ret = value.call(rsrc_hsh[name.to_sym].to_s)
                if ret != true
                  ret = false
                  (@errors ||= []) << "#{name.to_s} `#{rsrc_hsh[name.to_sym].inspect}` passed to `#{value.to_s}` would be `true` but it's `#{ret}`"
                end
              else
                unless rsrc_hsh[name.to_sym].to_s == value.to_s
                  ret = false
                  (@errors ||= []) << "#{name.to_s} set to `#{value.inspect}` but it is set to `#{rsrc_hsh[name.to_sym].inspect}` in the catalogue"
                end
              end
            end
          end

          if @expected_undef_params
            @expected_undef_params.each do |name,value|
              if value.nil? then
                unless resource.send(:parameters)[name.to_sym].nil?
                  ret = false
                  (@errors ||= []) << "#{name.to_s} undefined"
                end
              elsif value.kind_of?(Regexp) then
                if rsrc_hsh[name.to_sym].to_s =~ value
                  ret = false
                  (@errors ||= []) << "#{name.to_s} not matching `#{value.inspect}` but its value of `#{rsrc_hsh[name.to_sym].inspect}` does"
                end
              elsif value.kind_of?(Array) then
                if Array(rsrc_hsh[name.to_sym]).flatten.join == value.flatten.join
                  ret = false
                  (@errors ||= []) << "#{name.to_s} not set to `#{value.inspect}` but it is set to `#{rsrc_hsh[name.to_sym].inspect}` in the catalogue"
                end
              else
                if rsrc_hsh[name.to_sym].to_s == value.to_s
                  ret = false
                  (@errors ||= []) << "#{name.to_s} not set to `#{value.inspect}` but it is set to `#{rsrc_hsh[name.to_sym].inspect}` in the catalogue"
                end
              end
            end
          end
        end

        ret
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
        if @expected_params
          @expected_params.each do |name, value|
            if value.kind_of?(Regexp)
              values << "#{name.to_s} matching #{value.inspect}"
            else
              values << "#{name.to_s} => #{value.inspect}"
            end
          end
        end

        if @expected_undef_params
          @expected_undef_params.each do |name, value|
            if value.nil?
              values << "#{name.to_s} undefined"
            elsif value.kind_of?(Regexp)
              values << "#{name.to_s} not matching #{value.inspect}"
            else
              values << "#{name.to_s} !> #{value.inspect}"
            end
          end
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
        @errors.nil? ? "" : " with #{@errors.join(', and parameter ')}"
      end
    end
  end
end
