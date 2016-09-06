module RSpec::Puppet
  # A raw string object, that is used by helpers to allow consumers to return non-quoted strings
  # as part of their params section.
  class RawString
    # Create a new RawString object
    # @param [String] value string to wrap
    def initialize(value)
      @value = value
    end

    # @return [String] raw string
    def inspect
      @value
    end
  end
end
