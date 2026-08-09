# frozen_string_literal: true

module LruRedux
  module TTL
    class ThreadSafeCache < Cache
      include ::LruRedux::Util::SafeSync

      def expire
        synchronize do
          super
        end
      end
    end
  end
end
