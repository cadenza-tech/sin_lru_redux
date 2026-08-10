# frozen_string_literal: true

require_relative '../support/cache_tests'
require_relative '../support/thread_safe_cache_tests'

module TestLruRedux
  class TestThreadSafeCache < Minitest::Test
    include CacheTests
    include ThreadSafeCacheTests

    private

    def cache_class
      ::LruRedux::ThreadSafeCache
    end
  end
end
