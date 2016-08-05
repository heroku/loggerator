module Loggerator
  module RequestStore
    class << self
      def clear!
        Thread.current[:request_store] = {}
      end

      def seed(env)
        store[:request_id] =
          env["REQUEST_IDS"] ? env["REQUEST_IDS"].join(",") : nil

        # a global context that evolves over the lifetime of the request, and is
        # used to tag all log messages that it produces
        store[:log_context] = {
          request_id: store[:request_id]
        }
      end

      def store
        Thread.current[:request_store] ||= {}
      end
    end
  end
end
