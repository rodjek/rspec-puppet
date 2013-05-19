module RSpec::Puppet
  module Errors
    class MatchError < StandardError
      attr_reader :param, :expected, :actual, :negative

      def initialize(param, expected, actual, negative)
        @param = param
        @expected = expected.inspect
        @actual = actual.inspect
        @negative = negative
      end

      def message
        if negative == true
          "#{param} not set to #{expected} but it is set to #{actual}"
        else
          "#{param} set to #{expected} but it is set to #{actual}"
        end
      end

      def to_s
        message
      end
    end

    class RegexpMatchError < MatchError
      def message
        if negative == true
          "#{param} not matching #{expected} but its value of #{actual} does"
        else
          "#{param} matching #{expected} but its value of #{actual} does not"
        end
      end
    end

    class ProcMatchError < MatchError
      def message
        if negative == true
          "#{param} passed to the block would not return `#{expected}` but it did"
        else
          "#{param} passed to the block would return `#{expected}` but it is `#{actual}`"
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
        "#{from} to come before #{to} in the graph"
      end
    end

    class RequireRelationshipError < RelationshipError
      def message
        "#{from} to require #{to} in the graph"
      end
    end

    class NotifyRelationshipError < RelationshipError
      def message
        "#{from} to notify #{to}"
      end
    end

    class SubscribeRelationshipError < RelationshipError
      def message
        "#{from} to be subscribed to #{to}"
      end
    end
  end
end
