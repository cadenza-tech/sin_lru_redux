# frozen_string_literal: true

require_relative '../../support/ttl_cache_tests'
require_relative '../../support/ttl_thread_safe_cache_tests'

module TestLruRedux
  module Ttl
    class TestThreadSafeCache < Minitest::Test
      include TtlCacheTests
      include TtlThreadSafeCacheTests

      private

      def cache_class
        ::LruRedux::TTL::ThreadSafeCache
      end
    end
  end
end
