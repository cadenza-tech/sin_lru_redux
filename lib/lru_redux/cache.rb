# frozen_string_literal: true

class LruRedux::Cache
  attr_reader :max_size, :ignore_nil

  def initialize(*args)
    max_size, ignore_nil, _ = args

    max_size ||= 1000
    ignore_nil ||= false

    validate_max_size!(max_size)
    validate_ignore_nil!(ignore_nil)

    @max_size = max_size
    @ignore_nil = ignore_nil
    @data = {}
  end

  def max_size=(new_max_size)
    validate_max_size!(new_max_size)

    @max_size = new_max_size
    evict_excess
  end

  def ttl=(_)
    nil
  end

  def ignore_nil=(new_ignore_nil)
    validate_ignore_nil!(new_ignore_nil)

    @ignore_nil = new_ignore_nil
    evict_nil
  end

  def getset(key)
    key_found = true
    value = @data.delete(key) { key_found = false }

    if key_found
      @data[key] = value
    else
      result = yield
      store_item(key, result)
      result
    end
  end

  def fetch(key)
    key_found = true
    value = @data.delete(key) { key_found = false }

    if key_found
      @data[key] = value
    else
      yield if block_given? # rubocop:disable Style/IfInsideElse
    end
  end

  def [](key)
    key_found = true
    value = @data.delete(key) { key_found = false }
    return unless key_found

    @data[key] = value
  end

  def []=(key, val)
    store_item(key, val)
  end

  def each(&block)
    @data.to_a.reverse_each(&block)
  end
  # Used further up the chain, non thread safe each
  alias_method :each_unsafe, :each

  def to_a
    @data.to_a.reverse
  end

  def values
    @data.values.reverse
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

  private

  # For cache validation only, ensure all is valid
  def valid?
    true
  end

  def validate_max_size!(max_size)
    unless max_size.is_a?(Numeric)
      raise ArgumentError.new(<<~ERROR)
        Invalid max_size: #{max_size.inspect}
        max_size must be a number.
      ERROR
    end
    return if max_size >= 1

    raise ArgumentError.new(<<~ERROR)
      Invalid max_size: #{max_size.inspect}
      max_size must be greater than or equal to 1.
    ERROR
  end

  def validate_ignore_nil!(ignore_nil)
    return if [true, false].include?(ignore_nil)

    raise ArgumentError.new(<<~ERROR)
      Invalid ignore_nil: #{ignore_nil.inspect}
      ignore_nil must be a boolean value.
    ERROR
  end

  def evict_excess
    @data.shift while @data.size > @max_size
  end

  if RUBY_VERSION >= '2.6.0'
    def evict_nil
      return unless @ignore_nil

      @data.compact!
    end
  else
    def evict_nil
      return unless @ignore_nil

      @data.reject! { |_key, value| value.nil? }
    end
  end

  def store_item(key, val)
    @data.delete(key)
    @data[key] = val if !val.nil? || !@ignore_nil
    evict_excess
    val
  end
end
