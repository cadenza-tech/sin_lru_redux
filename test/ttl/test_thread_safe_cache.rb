# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'test_cache'

module Ttl
  class TestThreadSafeCache < Ttl::TestCache
    def setup
      Timecop.freeze(Time.now)
      @cache = LruRedux::TTL::ThreadSafeCache.new(3, 5 * 60, false)
      @data_name = :@data_lru
    end

    def test_recursion
      @cache[:a] = 1
      @cache[:b] = 2
      @cache[:c] = 3

      # Should not blow up
      @cache.each do |key, _value| # rubocop:disable Style/HashEachMethods
        @cache[key]
      end
    end
  end
end
