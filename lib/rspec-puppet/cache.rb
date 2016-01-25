module RSpec::Puppet
  class Cache

    MAX_ENTRIES = 16

    # @param [Proc] default_proc The default proc to use to fetch objects on cache miss
    def initialize(&default_proc)
      @default_proc = default_proc
      @cache = {}
      @lra = []
    end

    def get(*args, &blk)
      expire!
      if !@cache.has_key? args
        @cache[args] = (blk || @default_proc).call(*args)
        @lra << args
      end

      @cache[args]
    end

    private

    def expire!
      expired = @lra.slice!(0, @lra.size - MAX_ENTRIES)
      expired.each { |key| @cache.delete(key) } if expired
    end
  end
end
