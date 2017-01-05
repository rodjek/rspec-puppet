module RSpec::Puppet
  module TypeAliasMatchers
    class AllowValue
      def initialize(values)
        @values = values
        @error_msgs = []
      end

      def matches?(catalogue)
        matches = @values.map do |test_value|
          begin
            catalogue.call(test_value)
            true
          rescue Puppet::Error => e
            @error_msgs << e.message
            false
          end
        end
        matches.all?
      end

      def description
        if @values.length == 1
          "match value #{@values.first.inspect}"
        else
          "match values #{@values.map(&:inspect).join(', ')}"
        end
      end

      def failure_message
        "expected that the type alias would " + description + " but it raised the #{@error_msgs.length == 1 ? 'error' : 'errors'} #{@error_msgs.join(', ')}"
      end

      def failure_message_when_negated
        "expected that the type alias would not " + description + " but it does"
      end
    end

    def allow_value(*values)
      RSpec::Puppet::TypeAliasMatchers::AllowValue.new(values)
    end

    alias_method :allow_values, :allow_value
  end
end
