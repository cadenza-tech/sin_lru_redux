# frozen_string_literal: true

class LruRedux::TTL::ThreadSafeCache < LruRedux::TTL::Cache
  include LruRedux::Util::SafeSync
end
