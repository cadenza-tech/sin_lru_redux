# frozen_string_literal: true

require_relative '../support/cache_tests'

module TestLruRedux
  class TestCache < Minitest::Test
    include CacheTests

    private

    def cache_class
      ::LruRedux::Cache
    end
  end
end
