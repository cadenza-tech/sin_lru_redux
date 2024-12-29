# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'test_cache'

module Ttl
  class TestThreadSafeCache < Ttl::TestCache
    def setup
      Timecop.freeze(Time.now)
      @c = LruRedux::TTL::ThreadSafeCache.new(3, 5 * 60)
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
end
