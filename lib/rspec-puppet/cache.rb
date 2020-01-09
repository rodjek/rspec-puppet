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
      key = Marshal.load(Marshal.dump(args))
      if @cache.has_key?(key)
        # Cache hit
        # move that entry last to make it "most recenty used"
        @lra.insert(-1, @lra.delete_at(@lra.index(args)))
      else
        # Cache miss
        # Ensure room by evicting least recently used if no space left
        expire!
        @cache[args] = (blk || @default_proc).call(*args)
        @lra << args
      end

      @cache[key]
    end

    private

    def expire!
      # delete one entry (the oldest) when there is no room in cache
      @cache.delete(@lra.shift) if @cache.size == MAX_ENTRIES
    end
  end
end
