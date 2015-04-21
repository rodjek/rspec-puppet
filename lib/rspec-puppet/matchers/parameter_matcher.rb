module RSpec::Puppet
  module ManifestMatchers
    class ParameterMatcher
      include RSpec::Puppet::Errors

      # @param parameter [Symbol] The specific parameter to check
      # @param value [Object] The expected data to match the parameter against
      # @param type [:should, :not] Whether the given parameter should match
      def initialize(parameter, value, type)
        @parameter, @value, @type = parameter, value, type

        @should_match = (type == :should)

        @errors = []
      end

      # Ensure that the actual parameter matches the expected parameter.
      #
      # @param resource [Hash<Symbol, Object>] A hash representing a Puppet
      #   resource in the catalog
      #
      # @return [true, false]
      def matches?(resource)

        @resource = resource

        actual   = @resource[@parameter]
        expected = @value

        # Puppet flattens an array with a single value into just the value and
        # this can cause confusion when testing as people expect when you put
        # an array in, you'll get an array out.
        actual = [*actual] if expected.is_a?(Array)

        retval = check(expected, actual)

        unless retval
          @errors << MatchError.new(@parameter, expected, actual, !@should_match)
        end

        retval
      end

      # @!attribute [r] errors
      #   @return [Array<Object < StandardError>] All expectation errors
      #     generated on this parameter.
      attr_reader :errors

      private

      # Recursively check that the `expected` and `actual` data structures match
      #
      # @param expected [Object] The expected value of the given resource param
      # @param actual [Object] The value of the resource as found in the catalogue
      #
      # @return [true, false] If the resource matched
      def check(expected, actual)
        return false if actual.nil? && !expected.nil?
        case expected
        when Proc
          check_proc(expected, actual)
        when Regexp
          check_regexp(expected, actual)
        when Hash
          check_hash(expected, actual)
        when Array
          check_array(expected, actual)
        else
          check_string(expected, actual)
        end
      end

      def check_proc(expected, actual)
        expected_return = @should_match
        actual_return   = expected.call(actual)

        actual_return == expected_return
      end

      def check_regexp(expected, actual)
        !!(actual.to_s.match expected) == @should_match
      end

      # Ensure that two hashes have the same number of keys, and that for each
      # key in the expected hash, there's a stringified key in the actual hash
      # with a matching value.
      def check_hash(expected, actual)
        op = @should_match ? :"==" : :"!="

        unless expected.keys.size.send(op, actual.keys.size)
          return false
        end

        expected.keys.all? do |key|
          check(expected[key], actual[key])
        end
      end

      def check_array(expected, actual)
        op = @should_match ? :"==" : :"!="

        unless expected.size.send(op, actual.size)
          return false
        end

        (0...expected.size).all? do |index|
          check(expected[index], actual[index])
        end
      end

      def check_string(expected, actual)
        (expected.to_s == actual.to_s) == @should_match
      end
    end
  end
end
