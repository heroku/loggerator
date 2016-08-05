module Loggerator
  module RequestStore
    class << self
      def clear!
        Thread.current[:request_store] = {}
      end

      def seed(env)

        request_ids = []
        request_ids << env['REQUEST_ID'] if env['REQUEST_ID']
        request_ids << env['REQUEST_IDS'] ? env['REQUEST_IDS'] : []
        request_ids = request_ids.join(',')

        store[:request_id] = request_ids == '' ? nil : request_ids

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
