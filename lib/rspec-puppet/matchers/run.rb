module RSpec::Puppet
  module FunctionMatchers
    extend RSpec::Matchers::DSL

    matcher :run do
      match do |func_obj|
        if @params
          func = lambda { func_obj.call(@params) }
        else
          func = lambda { func_obj.call }
        end

        if @expected_error
          begin
            func.call
          rescue @expected_error
            #XXX check error string here
            true
          rescue
            false
          end
        else
          if @expected_return
            func.call == @expected_return
          else
            begin
              func.call
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
    end
  end
end
