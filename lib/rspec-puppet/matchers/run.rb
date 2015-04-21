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
            case @expected_return
            when Regexp
              @actual_return =~ @expected_return
            else
              @actual_return == @expected_return
            end
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
        # stringify immediatly to protect us from the params being changed by
        # the subject, e.g. with params.shift
        @func_args = @params.inspect[1..-2]
        self
      end

      def and_return(value)
        @expected_return = value
        if value.is_a? Regexp
          @desc = "match #{value.inspect}"
        else
          @desc = "return #{value.inspect}"
        end
        self
      end

      def and_raise_error(error_or_message, message=nil)
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
        "run #{func_name}(#{func_params}) and #{@desc}"
      end

      private
      def func_name
        if Puppet.version.to_f >= 4.0
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
