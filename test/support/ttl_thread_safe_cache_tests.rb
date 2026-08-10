# frozen_string_literal: true

require_relative 'thread_safe_cache_tests'

module TtlThreadSafeCacheTests
  include ThreadSafeCacheTests

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
