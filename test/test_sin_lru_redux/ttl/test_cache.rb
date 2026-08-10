# frozen_string_literal: true

require_relative '../../support/ttl_cache_tests'

module TestSinLruRedux
  module Ttl
    class TestCache < Minitest::Test
      include TtlCacheTests

      private

      def cache_class
        ::SinLruRedux::TTL::Cache
      end
    end
  end
end
