module RSpec::Puppet
  module FunctionMatchers
    class Run
      def matches?(func_obj)
        @func_obj = func_obj
        if @params
          if Puppet.version.to_f >= 4.0 and ! @func_obj.respond_to?(:receiver)
            @func = lambda { func_obj.call({}, *@params) }
          else
            @func = lambda { func_obj.call(@params) }
          end
        else
          if Puppet.version.to_f >= 4.0 and ! @func_obj.respond_to?(:receiver)
            @func = lambda { func_obj.call({}) }
          else
            @func = lambda { func_obj.call }
          end
        end

        begin
          @actual_return = @func.call
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
              return @actual_error.message =~ @expected_error_message
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
              return @actual_return =~ @expected_return
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
        if Puppet.version.to_f >= 4.0 and ! @func_ob and ! @func_obj.respond_to?(:receiver)
          @func_name ||= @func_obj.class.name
        else
          @func_name ||= @func_obj.name.to_s.gsub(/^function_/, '')
        end
      end

      def func_params
        @func_args
      end

      def failure_message_generic(type, func_obj)
        message = "expected #{func_name}(#{func_params}) to "
        message << "not " if type == :should_not

        if @has_expected_return
          message << "have returned #{@expected_return.inspect}"
          if type == :should
            message << " instead of #{@actual_return.inspect}"
          end
        else
          if @has_expected_error
            message << "have raised #{@expected_error.inspect}"
            if @expected_error_message
              message << " matching #{@expected_error_message.inspect}"
            end
          else
            message << "have run successfully"
          end
          if type == :should
            if @actual_error
              message << " instead of raising #{@actual_error.class.inspect}"
              if @expected_error_message
                message << "(#{@actual_error})"
              end
            elsif @has_returned
              message << " instead of returning #{@actual_return.class.inspect}"
            end
          end
        end
        message
      end
    end
  end
end
