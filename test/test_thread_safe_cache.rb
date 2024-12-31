# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'test_cache'

class TestThreadSafeCache < TestCache
  def setup
    @cache = LruRedux::ThreadSafeCache.new(3, false)
    @data_name = :@data
  end

  def test_validate_max_size!
    assert_raises(ArgumentError) do
      LruRedux::ThreadSafeCache.new('invalid', false)
    end
    assert_raises(ArgumentError) do
      LruRedux::ThreadSafeCache.new(0, false)
    end
  end

  def test_validate_ignore_nil!
    assert_raises(ArgumentError) do
      LruRedux::ThreadSafeCache.new(1, 'invalid')
    end
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
