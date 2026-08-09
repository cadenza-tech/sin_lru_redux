# frozen_string_literal: true

require_relative 'test_cache'

module TestLruRedux
  module Ttl
    class TestThreadSafeCache < TestCache
      def setup
        Timecop.freeze(Time.now)
        @cache = ::LruRedux::TTL::ThreadSafeCache.new(3, 5 * 60, false)
      end

      def teardown
        Timecop.return

        assert(@cache.send(:valid?))
      end

      def test_initialization
        assert_equal(3, @cache.max_size)
        assert_equal(300, @cache.ttl)
        refute(@cache.ignore_nil)
      end

      def test_validate_max_size!
        assert_raises(ArgumentError) do
          ::LruRedux::TTL::ThreadSafeCache.new('invalid', 0, false)
        end
        assert_raises(ArgumentError) do
          ::LruRedux::TTL::ThreadSafeCache.new(0, 0, false)
        end
      end

      def test_validate_ttl!
        assert_raises(ArgumentError) do
          ::LruRedux::TTL::ThreadSafeCache.new(1, 'invalid', false)
        end
        assert_raises(ArgumentError) do
          ::LruRedux::TTL::ThreadSafeCache.new(0, -1, false)
        end
      end

      def test_validate_ignore_nil!
        assert_raises(ArgumentError) do
          ::LruRedux::TTL::ThreadSafeCache.new(1, 0, 'invalid')
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

      def test_synchronization
        [:expire, :length, :size].each do |method_name|
          order = []
          lock_acquired = Queue.new
          thread = Thread.new do
            @cache.synchronize do
              lock_acquired.push(true)
              sleep(0.1)
              order.push(:lock_holder)
            end
          end

          lock_acquired.pop
          @cache.public_send(method_name)
          order.push(method_name)
          thread.join

          assert_equal([:lock_holder, method_name], order)
        end
      end
    end
  end
end
