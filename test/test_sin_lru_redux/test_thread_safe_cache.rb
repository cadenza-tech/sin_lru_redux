# frozen_string_literal: true

require_relative 'test_cache'

module TestSinLruRedux
  class TestThreadSafeCache < TestCache
    def setup
      @cache = ::SinLruRedux::ThreadSafeCache.new(3, false)
    end

    def test_validate_max_size!
      assert_raises(ArgumentError) do
        ::SinLruRedux::ThreadSafeCache.new('invalid', false)
      end
      assert_raises(ArgumentError) do
        ::SinLruRedux::ThreadSafeCache.new(0, false)
      end
    end

    def test_validate_ignore_nil!
      assert_raises(ArgumentError) do
        ::SinLruRedux::ThreadSafeCache.new(1, 'invalid')
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
end
