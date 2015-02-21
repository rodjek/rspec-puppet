module RSpec::Puppet
  module Errors
    class MatchError < StandardError
      attr_reader :param, :expected, :actual, :negative

      def initialize(param, expected, actual, negative)
        @param = param
        @expected = expected
        @actual = actual
        @negative = negative
      end

      def message
        if @param.to_s == 'content' and expected.is_a?( String )
          if negative == true
            "#{param} not set to supplied string"
          else
            "#{param} set to supplied string"
          end
        else
          if negative == true
            "#{param} not set to #{expected.inspect} but it is set to #{actual.inspect}"
          else
            "#{param} set to #{expected.inspect} but it is set to #{actual.inspect}"
          end
        end
      end

      def to_s
        message
      end
    end

    class RegexpMatchError < MatchError
      def message
        if negative == true
          "#{param} not matching #{expected.inspect} but its value of #{actual.inspect} does"
        else
          "#{param} matching #{expected.inspect} but its value of #{actual.inspect} does not"
        end
      end
    end

    class ProcMatchError < MatchError
      def message
        if negative == true
          "#{param} passed to the block would not return `#{expected.inspect}` but it did"
        else
          "#{param} passed to the block would return `#{expected.inspect}` but it is `#{actual.inspect}`"
        end
      end
    end

    class RelationshipError < StandardError
      attr_reader :from, :to

      def initialize(from, to)
        @from = from
        @to = to
      end

      def to_s
        message
      end
    end

    class BeforeRelationshipError < RelationshipError
      def message
        "that comes before #{to}"
      end
    end

    class RequireRelationshipError < RelationshipError
      def message
        "that requires #{to}"
      end
    end

    class NotifyRelationshipError < RelationshipError
      def message
        "that notifies #{to}"
      end
    end

    class SubscribeRelationshipError < RelationshipError
      def message
        "that is subscribed to #{to}"
      end
    end
  end
end
