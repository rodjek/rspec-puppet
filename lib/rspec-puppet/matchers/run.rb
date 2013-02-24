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
        func_name = func_obj.name.to_s.gsub(/^function_/, '')
        func_params = @params.inspect[1..-2]

        if @expected_return
          "expected #{func_name}(#{func_params}) to have returned #{@expected_return.inspect} instead of #{@actual_return.inspect}"
        elsif @expected_error
          "expected #{func_name}(#{func_params}) to have raised #{@expected_error.inspect}"
        else
          "expected #{func_name}(#{func_params}) to have run successfully"
        end
      end

      failure_message_for_should_not do |func_obj|
        func_name = func_obj.name.gsub(/^function_/, '')
        func_params = @params.inspect[1..-2]

        if @expected_return
          "expected #{func_name}(#{func_params}) to not have returned #{@expected_return.inspect}"
        elsif @expected_error
          "expected #{func_name}(#{func_params}) to not have raised #{@expected_error.inspect}"
        else
          "expected #{func_name}(#{func_params}) to not have run successfully"
        end
      end
    end
  end
end
