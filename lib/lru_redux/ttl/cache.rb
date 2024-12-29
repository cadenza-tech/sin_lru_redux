# frozen_string_literal: true

module LruRedux
  module TTL
    class Cache
      attr_reader :max_size, :ttl, :ignore_nil

      def initialize(*args)
        max_size, ttl, ignore_nil = args

        max_size ||= 1000
        ttl ||= :none
        ignore_nil ||= false

        raise ArgumentError.new(:max_size) unless valid_max_size?(max_size)
        raise ArgumentError.new(:ttl) unless valid_ttl?(ttl)
        raise ArgumentError.new(:ignore_nil) unless valid_ignore_nil?(ignore_nil)

        @max_size = max_size
        @ttl = ttl
        @ignore_nil = ignore_nil
        @data_lru = {}
        @data_ttl = {}
      end

      def max_size=(max_size)
        max_size ||= @max_size

        raise ArgumentError.new(:max_size) unless valid_max_size?(max_size)

        @max_size = max_size

        resize
      end

      def ttl=(ttl)
        ttl ||= @ttl
        raise ArgumentError.new(:ttl) unless valid_ttl?(ttl)

        @ttl = ttl

        ttl_evict
      end

      def ignore_nil=(ignore_nil)
        ignore_nil ||= @ignore_nil
        raise ArgumentError.new(:ignore_nil) unless valid_ignore_nil?(ignore_nil)

        @ignore_nil = ignore_nil
      end

      def getset(key)
        ttl_evict

        found = true
        value = @data_lru.delete(key) { found = false }
        if found
          @data_lru[key] = value
        else
          result = yield

          if !result.nil? || !@ignore_nil
            @data_lru[key] = result
            @data_ttl[key] = Time.now.to_f

            if @data_lru.size > @max_size
              key, _ = @data_lru.first

              @data_ttl.delete(key)
              @data_lru.delete(key)
            end
          end

          result
        end
      end

      def fetch(key)
        ttl_evict

        found = true
        value = @data_lru.delete(key) { found = false }
        if found
          @data_lru[key] = value
        else
          yield if block_given? # rubocop:disable Style/IfInsideElse
        end
      end

      def [](key)
        ttl_evict

        found = true
        value = @data_lru.delete(key) { found = false }
        @data_lru[key] = value if found
      end

      def []=(key, val)
        ttl_evict

        @data_lru.delete(key)
        @data_ttl.delete(key)

        @data_lru[key] = val
        @data_ttl[key] = Time.now.to_f

        if @data_lru.size > @max_size
          key, _ = @data_lru.first

          @data_ttl.delete(key)
          @data_lru.delete(key)
        end

        val # rubocop:disable Lint/Void
      end

      def each(&block)
        ttl_evict

        array = @data_lru.to_a
        array.reverse!.each(&block)
      end

      # used further up the chain, non thread safe each
      alias_method :each_unsafe, :each

      def to_a
        ttl_evict

        array = @data_lru.to_a
        array.reverse!
      end

      def values
        ttl_evict

        vals = @data_lru.values
        vals.reverse!
      end

      def delete(key)
        ttl_evict

        @data_ttl.delete(key)
        @data_lru.delete(key)
      end

      alias_method :evict, :delete

      def key?(key)
        ttl_evict

        @data_lru.key?(key)
      end

      alias_method :has_key?, :key?

      def clear
        @data_ttl.clear
        @data_lru.clear
      end

      def expire
        ttl_evict
      end

      def count
        @data_lru.size
      end

      protected

      # for cache validation only, ensures all is sound
      def valid?
        @data_lru.size == @data_ttl.size
      end

      def ttl_evict
        return if @ttl == :none

        ttl_horizon = Time.now.to_f - @ttl
        key, time = @data_ttl.first

        until time.nil? || time > ttl_horizon
          @data_ttl.delete(key)
          @data_lru.delete(key)

          key, time = @data_ttl.first
        end
      end

      def resize
        ttl_evict

        while @data_lru.size > @max_size
          key, _ = @data_lru.first

          @data_ttl.delete(key)
          @data_lru.delete(key)
        end
      end

      private

      def valid_max_size?(max_size)
        return true if max_size.is_a?(Integer) && max_size >= 1

        false
      end

      def valid_ttl?(ttl)
        return true if ttl == :none
        return true if ttl.is_a?(Numeric) && ttl >= 0

        false
      end

      def valid_ignore_nil?(ignore_nil)
        return true if [true, false].include?(ignore_nil)

        false
      end
    end
  end
end
