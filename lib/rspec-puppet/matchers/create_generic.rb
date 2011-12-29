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
      def method_missing(method, *args, &block)
        if method.to_s =~ /^with_/
          param = method.to_s.gsub(/^with_/, '')
          (@expected_params ||= []) << [param, args[0]]
          self
        elsif method.to_s =~ /^without_/
          param = method.to_s.gsub(/^without_/, '')
          (@expected_undef_params ||= []) << param
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
          if @expected_params
            @expected_params.each do |name, value|
              unless resource.send(:parameters)[name.to_sym].to_s == value.to_s
                ret = false
                (@errors ||= []) << "#{name.to_s} set to `#{value.inspect}`"
              end
            end
          end

          if @expected_undef_params
            @expected_undef_params.each do |name|
              unless resource.send(:parameters)[name.to_sym].nil?
                ret = false
                (@errors ||= []) << "#{name.to_s} undefined"
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
        "create #{@referenced_type}[#{@title}]"
      end

    private

      def referenced_type(type)
        type.split('__').map { |r| r.capitalize }.join('::')
      end

      def errors
        @errors.nil? ? "" : " with #{@errors.join(', ')}"
      end
    end

    def method_missing(method, *args, &block)
      return RSpec::Puppet::ManifestMatchers::CreateGeneric.new(method, *args, &block) if method.to_s =~ /^(create|contain)_/
      super
    end
  end
end
