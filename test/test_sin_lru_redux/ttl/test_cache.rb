# frozen_string_literal: true

require_relative '../test_cache'

module TestSinLruRedux
  module Ttl
    class TestCache < ::TestSinLruRedux::TestCache
      def setup
        Timecop.freeze(Time.now)
        @cache = ::SinLruRedux::TTL::Cache.new(3, 5 * 60, false)
      end

      def test_validate_max_size!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::Cache.new('invalid', 0, false)
        end
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::Cache.new(0, 0, false)
        end
      end

      def test_validate_ttl!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::Cache.new(1, 'invalid', false)
        end
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::Cache.new(0, -1, false)
        end
      end

      def test_validate_ignore_nil!
        assert_raises(ArgumentError) do
          ::SinLruRedux::TTL::Cache.new(1, 0, 'invalid')
        end
      end
    end
  end
end
