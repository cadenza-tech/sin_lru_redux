# frozen_string_literal: true

require_relative 'test_helper'

class TestCache < Minitest::Test
  def setup
    @cache = LruRedux::Cache.new(3, false)
  end

  def test_initialization
    assert_equal(3, @cache.max_size)
    refute(@cache.ignore_nil)
  end

  def test_max_size_set
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))

    @cache.max_size = 2

    assert_equal(2, @cache.max_size)
    assert_equal({ b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))

    @cache.max_size = 3

    assert_equal(3, @cache.max_size)
    assert_equal({ b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))

    @cache[:d] = 4

    assert_equal({ b: 2, c: 3, d: 4 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_max_size_set_to_nil
    assert_raises(ArgumentError) do
      @cache.max_size = nil
    end
  end

  def test_ignore_nil_set
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = nil

    assert_equal({ a: 1, b: 2, c: nil }, @cache.instance_variable_get(:@data_lru))

    @cache.ignore_nil = true

    assert(@cache.ignore_nil)
    assert_equal({ a: 1, b: 2 }, @cache.instance_variable_get(:@data_lru))

    @cache[:b] = nil

    assert_nil(@cache[:b])
    assert_equal({ a: 1 }, @cache.instance_variable_get(:@data_lru))

    @cache.ignore_nil = false

    refute(@cache.ignore_nil)
    assert_equal({ a: 1 }, @cache.instance_variable_get(:@data_lru))

    @cache[:b] = 2

    assert_equal({ a: 1, b: 2 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_ignore_nil_set_to_nil
    assert_raises(ArgumentError) do
      @cache.ignore_nil = nil
    end
  end

  def test_getset
    @cache[:a] = 1
    @cache[:b] = 2
    result = @cache.getset(:c) { 3 }

    assert_equal(3, result)
    assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_fetch
    @cache[:a] = 1
    @cache[:b] = nil
    result_a = @cache.fetch(:a) { 2 } # rubocop:disable Style/RedundantFetchBlock
    result_b = @cache.fetch(:b) { 3 } # rubocop:disable Style/RedundantFetchBlock
    result_c = @cache.fetch(:c) { 4 } # rubocop:disable Style/RedundantFetchBlock

    assert_equal(1, result_a)
    assert_nil(result_b)
    assert_equal(4, result_c)
    assert_equal({ a: 1, b: nil }, @cache.instance_variable_get(:@data_lru))
  end

  def test_set_and_get
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    assert_equal({ a: 1, b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))

    assert_equal(4, @cache[:c] = 4)
    assert_equal({ a: 1, b: 2, c: 4 }, @cache.instance_variable_get(:@data_lru))

    assert_equal(1, @cache[:a])
    assert_equal({ b: 2, c: 4, a: 1 }, @cache.instance_variable_get(:@data_lru))

    @cache[:d] = 5

    assert_equal({ c: 4, a: 1, d: 5 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_each
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    keys = []
    values = []
    @cache.each do |key, value|
      keys << key
      values << value
    end

    assert_equal([:c, :b, :a], keys)
    assert_equal([3, 2, 1], values)
  end

  def test_to_a
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    assert_equal([[:c, 3], [:b, 2], [:a, 1]], @cache.to_a)
  end

  def test_values
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    assert_equal([3, 2, 1], @cache.values)
  end

  def test_delete
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3
    @cache.delete(:a)

    assert_equal({ b: 2, c: 3 }, @cache.instance_variable_get(:@data_lru))
    assert_nil(@cache[:a])

    assert_equal(2, @cache.delete(:b))

    # Regression test for a bug in the legacy delete method
    @cache[:d] = 4
    @cache[:e] = 5
    @cache[:f] = 6

    assert_equal({ d: 4, e: 5, f: 6 }, @cache.instance_variable_get(:@data_lru))
    assert_nil(@cache[:a])
    assert_nil(@cache[:b])
    assert_nil(@cache[:c])
  end

  def test_key?
    @cache[:a] = 1

    assert(@cache.key?(:a))
    refute(@cache.key?(:b))
  end

  def test_clear
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    @cache.clear

    assert_empty(@cache.instance_variable_get(:@data_lru))
  end

  def test_count
    @cache[:a] = 1
    @cache[:b] = 2
    @cache[:c] = 3

    assert_equal(3, @cache.count)
  end

  def test_validate_max_size!
    assert_raises(ArgumentError) do
      LruRedux::Cache.new('invalid', false)
    end
    assert_raises(ArgumentError) do
      LruRedux::Cache.new(0, false)
    end
  end

  def test_validate_ignore_nil!
    assert_raises(ArgumentError) do
      LruRedux::Cache.new(1, 'invalid')
    end
  end

  def test_evict_excess
    @cache.instance_variable_set(:@data_lru, { a: 1, b: 2, c: 3, d: 4, e: 5 })

    @cache.send(:evict_excess)

    assert_equal({ c: 3, d: 4, e: 5 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_evict_nil
    @cache.ignore_nil = true
    @cache.instance_variable_set(:@data_lru, { a: 1, b: 2, c: nil, d: 4, e: nil })

    @cache.send(:evict_nil)

    assert_equal({ a: 1, b: 2, d: 4 }, @cache.instance_variable_get(:@data_lru))
  end

  def test_store_item
    @cache.instance_variable_set(:@data_lru, { a: 1, b: 2, c: 3 })

    @cache.send(:store_item, :d, 4)

    assert_equal({ b: 2, c: 3, d: 4 }, @cache.instance_variable_get(:@data_lru))

    assert_equal(5, @cache.send(:store_item, :d, 5))

    assert_equal({ b: 2, c: 3, d: 5 }, @cache.instance_variable_get(:@data_lru))
  end
end
