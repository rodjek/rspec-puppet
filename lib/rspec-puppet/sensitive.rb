module RSpec::Puppet
  # A wrapper representing Sensitive data type, eg. in class params.
  class Sensitive
    # Create a new Sensitive object
    # @param [Object] value to wrap
    def initialize(value)
      @value = value
    end

    # @return the wrapped value
    def unwrap
      @value
    end

    # @return true
    def sensitive?
      true
    end

    # @return inspect of the wrapped value, inside Sensitive()
    def inspect
      "Sensitive(#{@value.inspect})"
    end

    # Check for equality with another value.
    # If compared to Puppet Sensitive type, it compares the wrapped values.

    # @param other [#unwrap, Object] value to compare to
    def == other
      if other.respond_to? :unwrap
        return unwrap == other.unwrap
      else
        super
      end
    end
  end
end