require_relative 'loggerator'

module Loggerator
  module Namespace
    include Loggerator

    def log(data={}, &blk)
      log_namespace!
      super
    end

    def log_error(e, data={})
      log_namespace!
      super
    end

    private
      def log_namespace!
        self.local_context = { ns: self.class.name }
      end
  end
end
