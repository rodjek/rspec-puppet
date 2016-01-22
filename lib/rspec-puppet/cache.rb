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
      if @cache.has_key? args
        # Cache hit
        # move that entry last to make it "most recenty used"
        @ira.insert(-1, @ira.delete_at(@ira.index(args)))
      else
        # Cache miss
        # Ensure room by evicting least recently used if no space left
        expire!
        @cache[args] = (blk || @default_proc).call(*args)
        @lra << args
      end

      @cache[args]
    end

    private

    def expire!
      # delete one entry (the oldest) when there is no room in cache
      @cache.delete(@lra.shift) if @cached.size == MAX_ENTRIES
    end
  end
end
