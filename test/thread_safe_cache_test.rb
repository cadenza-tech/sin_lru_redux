# frozen_string_literal: true

require './test/cache_test'

class ThreadSafeCacheTest < CacheTest
  def setup
    @c = LruRedux::ThreadSafeCache.new(3)
  end

  def test_recursion
    @c[:a] = 1
    @c[:b] = 2

    # should not blow up
    @c.each do |k, _| # rubocop:disable Style/HashEachMethods
      @c[k]
    end
  end
end
