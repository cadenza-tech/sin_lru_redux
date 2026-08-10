# frozen_string_literal: true

require_relative '../support/cache_tests'

module TestSinLruRedux
  class TestCache < Minitest::Test
    include CacheTests

    private

    def cache_class
      ::SinLruRedux::Cache
    end
  end
end
