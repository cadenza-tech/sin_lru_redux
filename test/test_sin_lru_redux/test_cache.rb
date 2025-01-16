# frozen_string_literal: true

require_relative '../test_lru_redux/test_cache'

module TestSinLruRedux
  class TestCache < ::TestLruRedux::TestCache
    def setup
      @cache = ::SinLruRedux::Cache.new(3, false)
    end

    def test_validate_max_size!
      assert_raises(ArgumentError) do
        ::SinLruRedux::Cache.new('invalid', false)
      end
      assert_raises(ArgumentError) do
        ::SinLruRedux::Cache.new(0, false)
      end
    end

    def test_validate_ignore_nil!
      assert_raises(ArgumentError) do
        ::SinLruRedux::Cache.new(1, 'invalid')
      end
    end
  end
end
