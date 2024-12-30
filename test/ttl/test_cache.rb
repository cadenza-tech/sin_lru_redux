# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../test_cache'

module Ttl
  class TestCache < TestCache
    def setup
      Timecop.freeze(Time.now)
      @c = LruRedux::TTL::Cache.new(3, 5 * 60)
    end

    def teardown
      Timecop.return

      assert(@c.send(:valid?))
    end

    def test_ttl
      assert_equal(300, @c.ttl)

      @c.ttl = 10 * 60

      assert_equal(600, @c.ttl)
    end

    # TTL tests using Timecop
    def test_ttl_eviction_on_access
      @c[:a] = 1
      @c[:b] = 2

      Timecop.freeze(Time.now + (5.5 * 60))

      @c[:c] = 3

      assert_equal([[:c, 3]], @c.to_a)
    end

    def test_ttl_eviction_on_expire
      @c[:a] = 1
      @c[:b] = 2

      Timecop.freeze(Time.now + (5.5 * 60))

      @c.expire

      assert_empty(@c.to_a)
    end

    def test_ttl_eviction_on_new_max_size
      @c[:a] = 1
      @c[:b] = 2

      Timecop.freeze(Time.now + (5.5 * 60))

      @c.max_size = 10

      assert_empty @c.to_a
    end

    def test_ttl_eviction_on_new_ttl
      @c[:a] = 1
      @c[:b] = 2

      Timecop.freeze(Time.now + (5.5 * 60))

      @c.ttl = 10 * 60

      assert_equal([[:b, 2], [:a, 1]], @c.to_a)

      @c.ttl = 2 * 60

      assert_empty(@c.to_a)
    end

    def test_ttl_precedence_over_lru
      @c[:a] = 1

      Timecop.freeze(Time.now + 60)

      @c[:b] = 2
      @c[:c] = 3

      @c[:a]

      assert_equal([[:a, 1], [:c, 3], [:b, 2]], @c.to_a)

      Timecop.freeze(Time.now + (4.5 * 60))

      @c[:d] = 4

      assert_equal([[:d, 4], [:a, 1], [:c, 3]], @c.to_a)
    end
  end
end
