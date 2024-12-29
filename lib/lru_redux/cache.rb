# frozen_string_literal: true

class LruRedux::Cache
  def initialize(*args)
    max_size, ignore_nil, _ = args

    max_size ||= 1000
    ignore_nil ||= false

    raise ArgumentError.new(:max_size) unless valid_max_size?(max_size)
    raise ArgumentError.new(:ignore_nil) unless valid_ignore_nil?(ignore_nil)

    @max_size = max_size
    @ignore_nil = ignore_nil
    @data = {}
  end

  def max_size=(max_size)
    max_size ||= @max_size

    raise ArgumentError.new(:max_size) unless valid_max_size?(max_size)

    @max_size = max_size

    @data.shift while @data.size > @max_size
  end

  def ttl=(_)
    nil
  end

  def ignore_nil=(ignore_nil)
    ignore_nil ||= @ignore_nil
    raise ArgumentError.new(:ignore_nil) unless valid_ignore_nil?(ignore_nil)

    @ignore_nil = ignore_nil
  end

  def getset(key)
    found = true
    value = @data.delete(key) { found = false }
    if found
      @data[key] = value
    else
      result = @data[key] = yield
      @data.shift if @data.length > @max_size
      result
    end
  end

  def fetch(key)
    found = true
    value = @data.delete(key) { found = false }
    if found
      @data[key] = value
    else
      yield if block_given? # rubocop:disable Style/IfInsideElse
    end
  end

  def [](key)
    found = true
    value = @data.delete(key) { found = false }
    @data[key] = value if found
  end

  def []=(key, val)
    @data.delete(key)
    @data[key] = val
    @data.shift if @data.length > @max_size
    val # rubocop:disable Lint/Void
  end

  def each(&block)
    array = @data.to_a
    array.reverse!.each(&block)
  end

  # used further up the chain, non thread safe each
  alias_method :each_unsafe, :each

  def to_a
    array = @data.to_a
    array.reverse!
  end

  def values
    vals = @data.values
    vals.reverse!
  end

  def delete(key)
    @data.delete(key)
  end

  alias_method :evict, :delete

  def key?(key)
    @data.key?(key)
  end

  alias_method :has_key?, :key?

  def clear
    @data.clear
  end

  def count
    @data.size
  end

  protected

  # for cache validation only, ensures all is sound
  def valid?
    true
  end

  private

  def valid_max_size?(max_size)
    return true if max_size.is_a?(Integer) && max_size >= 1

    false
  end

  def valid_ignore_nil?(ignore_nil)
    return true if [true, false].include?(ignore_nil)

    false
  end
end
