# frozen_string_literal: true

require_relative 'test_cache'

module TestSinLruRedux
  module Ttl
    class TestThreadSafeCache < TestCache
      def setup
        Timecop.freeze(Time.now)
        @cache = ::SinLruRedux::TTL::ThreadSafeCache.new(3, 5 * 60, false)
      end

      def test_validate_max_size!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::ThreadSafeCache.new('invalid', 0, false)
        end
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::ThreadSafeCache.new(0, 0, false)
        end
      end

      def test_validate_ttl!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::ThreadSafeCache.new(1, 'invalid', false)
        end
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::ThreadSafeCache.new(0, -1, false)
        end
      end

      def test_validate_ignore_nil!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::ThreadSafeCache.new(1, 0, 'invalid')
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
end
