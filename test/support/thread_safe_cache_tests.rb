# frozen_string_literal: true

require_relative '../test_helper'

module ThreadSafeCacheTests
  def test_recursion
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    # Must not deadlock: #each holds the lock while the block reads the cache
    @cache.each do |key, _value| # rubocop:disable Style/HashEachMethods
      @cache[key]
    end
  end
end
