module RSpec::Puppet
  module FunctionMatchers
    class Run
      def matches?(func_obj)
        @func_obj = func_obj

        @has_returned = false
        begin
          # `*nil` does not evaluate to "no params" on ruby 1.8 :-(
          @actual_return = @params.nil? ? @func_obj.execute : @func_obj.execute(*@params)
          @has_returned = true
        rescue Exception => e
          @actual_error = e
        end

        if @has_expected_error
          if @has_returned
            return false
          elsif @actual_error.is_a?(@expected_error)
            case @expected_error_message
            when nil
              return true
            when Regexp
              return !!(@actual_error.message =~ @expected_error_message)
            else
              return @actual_error.message == @expected_error_message
            end
          else # error did not match
            return false
          end
        elsif @has_expected_return
          if !@has_returned
            return false
          else
            case @expected_return
            when Regexp
              return !!(@actual_return =~ @expected_return)
            else
              return @actual_return == @expected_return
            end
          end
        else
          return @has_returned
        end
      end

      def with_params(*params)
        @params = params
        # stringify immediately to protect us from the params being changed by
        # the subject, e.g. with params.shift
        @func_args = @params.inspect[1..-2]
        self
      end

      def and_return(value)
        @has_expected_return = true
        @expected_return = value
        if value.is_a? Regexp
          @desc = "match #{value.inspect}"
        else
          @desc = "return #{value.inspect}"
        end
        self
      end

      def and_raise_error(error_or_message, message=nil)
        @has_expected_error = true
        case error_or_message
        when String, Regexp
          @expected_error, @expected_error_message = Exception, error_or_message
        else
          @expected_error, @expected_error_message = error_or_message, message
        end

        if @expected_error_message.is_a? Regexp
          @desc = "raise an #{@expected_error} with the message matching #{@expected_error_message.inspect}"
        else
          @desc = "raise an #{@expected_error}"
          unless @expected_error_message.nil?
            @desc += "with the message #{@expected_error_message.inspect}"
          end
        end
        self
      end

      def failure_message
        failure_message_generic(:should, @func_obj)
      end

      def failure_message_when_negated
        failure_message_generic(:should_not, @func_obj)
      end

      def description
        if @desc
          "run #{func_name}(#{func_params}) and #{@desc}"
        else
          "run #{func_name}(#{func_params}) without error"
        end
      end

      private
      def func_name
        @func_obj.func_name
      end

      def func_params
        @func_args
      end

      def failure_message_actual(type)
        if type != :should
          ''
        elsif @actual_error
          if @has_expected_return
            " instead of raising #{@actual_error.class.inspect}(#{@actual_error})\n#{@actual_error.backtrace.join("\n")}"
          else
            " instead of #{@actual_error.class.inspect}(#{@actual_error})\n#{@actual_error.backtrace.join("\n")}"
          end
        else # function has returned
          if @has_expected_error
            " instead of returning #{@actual_return.inspect}"
          else
            " instead of #{@actual_return.inspect}"
          end
        end
      end

      def failure_message_generic(type, func_obj)
        message = "expected #{func_name}(#{func_params}) to "
        message << "not " if type == :should_not

        if @has_expected_return
          message << "have returned #{@expected_return.inspect}"
        else
          if @has_expected_error
            message << "have raised #{@expected_error.inspect}"
            if @expected_error_message
              message << " matching #{@expected_error_message.inspect}"
            end
          else
            message << "have run successfully"
          end
        end
        message << failure_message_actual(type)
      end
    end
  end
end
