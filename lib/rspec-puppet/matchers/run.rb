module RSpec::Puppet
  module FunctionMatchers
    extend RSpec::Matchers::DSL

    matcher :run do
      match do |func_obj|
        if @params
          @func = lambda { func_obj.call(@params) }
        else
          @func = lambda { func_obj.call }
        end

        unless @expected_error.nil?
          result = false
          begin
            @func.call
          rescue Exception => e
            @actual_error = e.class
            if @actual_error == @expected_error
              result = true
            end
          end
          result
        else
          unless @expected_return.nil?
            @actual_return = @func.call
            @actual_return == @expected_return
          else
            begin
              @func.call
            rescue
              false
            end
            true
          end
        end
      end

      chain :with_params do |*params|
        @params = params
      end

      chain :and_return do |value|
        @expected_return = value
      end

      # XXX support error string and regexp
      chain :and_raise_error do |value|
        @expected_error = value
      end

      failure_message_for_should do |func_obj|
        failure_message_generic(:should, func_obj)
      end

      failure_message_for_should_not do |func_obj|
        failure_message_generic(:should_not, func_obj)
      end

      def failure_message_generic(type, func_obj)
        func_name = func_obj.name.gsub(/^function_/, '')
        func_params = @params.inspect[1..-2]

        message = "expected #{func_name}(#{func_params}) to "
        message << "not " if type == :should_not

        if @expected_return
          message << "have returned #{@expected_return.inspect}"
          if type == :should
            message << " instead of #{@actual_return.inspect}"
          end
        elsif @expected_error
          message << "have raised #{@expected_error.inspect}"
        else
          message << "have run successfully"
        end
        message
      end
    end
  end
end
