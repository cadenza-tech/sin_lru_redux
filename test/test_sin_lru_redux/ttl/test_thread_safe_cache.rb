# frozen_string_literal: true

require_relative '../../support/ttl_cache_tests'
require_relative '../../support/ttl_thread_safe_cache_tests'

module TestSinLruRedux
  module Ttl
    class TestThreadSafeCache < Minitest::Test
      include TtlCacheTests
      include TtlThreadSafeCacheTests

      private

      def cache_class
        ::SinLruRedux::TTL::ThreadSafeCache
      end
    end
  end
end
