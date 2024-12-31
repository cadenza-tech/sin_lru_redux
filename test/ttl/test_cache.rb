# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../test_cache'

module Ttl
  class TestCache < TestCache
    def setup
      Timecop.freeze(Time.now)
      @cache = LruRedux::TTL::Cache.new(3, 5 * 60)
      @data_name = :@data_lru
    end

    def teardown
      Timecop.return
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

      assert(@cache.send(:valid?))
    end

    def test_ttl_set_to_nil
      assert_raises(ArgumentError) do
        @cache.ttl = nil
      end
    end

    def test_getset
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

      assert(@cache.send(:valid?))
    end

    def test_expire
      @cache[:a] = 1
      @cache[:b] = 2
      @cache[:c] = 3

      assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(@data_name))

      Timecop.freeze(Time.now + (5 * 60))

      @cache.expire

      assert_empty(@cache.instance_variable_get(@data_name))

      assert(@cache.send(:valid?))
    end

    def test_evict_expired
      @cache.instance_variable_set(@data_name, { a: 1, b: 2, c: 3, d: 4 })
      @cache.instance_variable_set(:@data_ttl, { a: Time.now.to_f + (5 * 60), b: Time.now.to_f + (5 * 60), c: Time.now.to_f, d: Time.now.to_f })

      @cache.send(:evict_expired)

      @cache.instance_variable_set(@data_name, { c: 3, d: 4 })
      @cache.instance_variable_set(:@data_ttl, { c: Time.now.to_f, d: Time.now.to_f })

      assert(@cache.send(:valid?))
    end
  end
end
