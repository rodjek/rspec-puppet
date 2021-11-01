module RSpec::Puppet

  # Implements a simple hash-based version of Facter to be used in module tests
  # that use rspec-puppet.
  class FacterTestImpl
    def initialize
      @facts = {}
    end

    def value(fact_name)
      @facts[fact_name.to_s]
    end

    def clear
      @facts.clear
    end

    def to_hash
      @facts
    end

    def add(name, options = {}, &block)
      raise 'Facter.add expects a block' unless block_given?
      @facts[name.to_s] = instance_eval(&block)
    end

    # noop methods
    def debugging(arg); end

    def reset; end

    def search(*paths); end

    def setup_logging; end

    private

    def setcode(string = nil, &block)
      if block_given?
        value = block.call
      else
        value = string
      end

      value
    end
  end
end

