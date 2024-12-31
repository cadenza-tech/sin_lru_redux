# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'test_cache'

class TestThreadSafeCache < TestCache
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
