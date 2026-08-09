# frozen_string_literal: true

module SinLruRedux
  module TTL
    class ThreadSafeCache < Cache
      include ::SinLruRedux::Util::SafeSync

      def expire
        synchronize do
          super
        end
      end
    end
  end
end
