# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../test_cache'

module Ttl
  class TestCache < TestCache
    def setup
      Timecop.freeze(Time.now)
      @cache = LruRedux::TTL::Cache.new(3, 5 * 60, false)
      @data_name = :@data_lru
    end

    def teardown
      Timecop.return

      assert(@cache.send(:valid?))
    end

    def test_initialization
      assert_equal(3, @cache.max_size)
      assert_equal(300, @cache.ttl)
      refute(@cache.ignore_nil)
    end

    def test_ttl_set # rubocop:disable Metrics/AbcSize
      @cache[:a] = 1

      Timecop.freeze(Time.now + (3 * 60))

      @cache[:b] = 2
      @cache[:c] = 3

      assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(@data_name))

      @cache.ttl = 3 * 60

      assert_equal(180, @cache.ttl)
      assert_equal({ b: 2, c: 3 }, @cache.instance_variable_get(@data_name))

      @cache.ttl = 5 * 60

      assert_equal(300, @cache.ttl)
      assert_equal({ b: 2, c: 3 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + (5 * 60))

      @cache[:d] = 4

      assert_equal({ d: 4 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + (5 * 60))

      @cache.ttl = 10 * 60

      assert_equal({ d: 4 }, @cache.instance_variable_get(@data_name))

      @cache[:e] = 5

      assert_equal({ d: 4, e: 5 }, @cache.instance_variable_get(@data_name))
    end

    def test_ttl_set_to_nil
      assert_raises(ArgumentError) do
        @cache.ttl = nil
      end
    end

    def test_set_and_get # rubocop:disable Metrics/AbcSize
      @cache.max_size = 4

      @cache[:a] = 1
      @cache[:b] = 2
      @cache[:c] = 3
      @cache[:d] = 4

      assert_equal({ a: 1, b: 2, c: 3, d: 4 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + 60)

      assert_equal(5, @cache[:c] = 5)
      assert_equal({ a: 1, b: 2, d: 4, c: 5 }, @cache.instance_variable_get(@data_name))

      assert_equal(1, @cache[:a])
      assert_equal({ b: 2, d: 4, c: 5, a: 1 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + (4 * 60))

      @cache[:e] = 6

      assert_equal({ c: 5, a: 1, e: 6 }, @cache.instance_variable_get(@data_name))

      @cache[:f] = 7
      @cache[:g] = 8

      assert_equal({ a: 1, e: 6, f: 7, g: 8 }, @cache.instance_variable_get(@data_name))
    end

    def test_expire
      @cache[:a] = 1
      @cache[:b] = 2

      Timecop.freeze(Time.now + (1 * 60))

      @cache[:c] = 3

      assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + (4 * 60))

      @cache.expire

      assert_equal({ c: 3 }, @cache.instance_variable_get(@data_name))
    end

    def test_validate_max_size!
      assert_raises(ArgumentError) do
        LruRedux::TTL::Cache.new('invalid', 0, false)
      end
      assert_raises(ArgumentError) do
        LruRedux::TTL::Cache.new(0, 0, false)
      end
    end

    def test_validate_ttl!
      assert_raises(ArgumentError) do
        LruRedux::TTL::Cache.new(1, 'invalid', false)
      end
      assert_raises(ArgumentError) do
        LruRedux::TTL::Cache.new(0, -1, false)
      end
    end

    def test_validate_ignore_nil!
      assert_raises(ArgumentError) do
        LruRedux::TTL::Cache.new(1, 0, 'invalid')
      end
    end

    def test_evict_excess
      @cache.instance_variable_set(@data_name, { a: 1, b: 2, c: 3, d: 4, e: 5 })
      @cache.instance_variable_set(:@data_ttl, { a: Time.now.to_f, b: Time.now.to_f, c: Time.now.to_f, d: Time.now.to_f, e: Time.now.to_f })

      @cache.send(:evict_excess)

      assert_equal({ c: 3, d: 4, e: 5 }, @cache.instance_variable_get(@data_name))
      assert_equal({ c: Time.now.to_f, d: Time.now.to_f, e: Time.now.to_f }, @cache.instance_variable_get(:@data_ttl))
    end

    def test_evict_expired
      @cache.instance_variable_set(@data_name, { a: 1, b: 2, c: 3, d: 4 })
      @cache.instance_variable_set(:@data_ttl, { a: Time.now.to_f - (5 * 60), b: Time.now.to_f - (5 * 60), c: Time.now.to_f, d: Time.now.to_f })

      @cache.send(:evict_expired)

      assert_equal({ c: 3, d: 4 }, @cache.instance_variable_get(@data_name))
      assert_equal({ c: Time.now.to_f, d: Time.now.to_f }, @cache.instance_variable_get(:@data_ttl))
    end

    def test_evict_nil
      @cache.ignore_nil = true
      @cache.instance_variable_set(@data_name, { a: 1, b: 2, c: nil, d: 4, e: nil })
      @cache.instance_variable_set(:@data_ttl, { a: Time.now.to_f, b: Time.now.to_f, c: Time.now.to_f, d: Time.now.to_f, e: Time.now.to_f })

      @cache.send(:evict_nil)

      assert_equal({ a: 1, b: 2, d: 4 }, @cache.instance_variable_get(@data_name))
      assert_equal({ a: Time.now.to_f, b: Time.now.to_f, d: Time.now.to_f }, @cache.instance_variable_get(:@data_ttl))
    end
  end
end
