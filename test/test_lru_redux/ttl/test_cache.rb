# frozen_string_literal: true

require_relative '../../support/ttl_cache_tests'

module TestLruRedux
  module Ttl
    class TestCache < Minitest::Test
      include TtlCacheTests

      private

      def cache_class
        ::LruRedux::TTL::Cache
      end
    end
  end
end
