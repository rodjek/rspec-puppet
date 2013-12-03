module RSpec::Puppet
  module FunctionMatchers
    class Run
      def matches?(func_obj)
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
            if e.is_a?(@expected_error)
              case @expected_error_message
              when nil
                result = true
              when Regexp
                result = @expected_error_message =~ e.message
              else
                result = @expected_error_message == e.message
              end
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

      def with_params(*params)
        @params = params
        self
      end

      def and_return(value)
        @expected_return = value
        self
      end

      def and_raise_error(error_or_message, message=nil)
        case error_or_message
        when String, Regexp
          @expected_error, @expected_error_message = Exception, error_or_message
        else
          @expected_error, @expected_error_message = error_or_message, message
        end
        self
      end

      def failure_message_for_should(func_obj)
        failure_message_generic(:should, func_obj)
      end

      def failure_message_for_should_not(func_obj)
        failure_message_generic(:should_not, func_obj)
      end

      private
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
