# frozen_string_literal: true

class LruRedux::ThreadSafeCache < LruRedux::Cache
  include LruRedux::Util::SafeSync
end
