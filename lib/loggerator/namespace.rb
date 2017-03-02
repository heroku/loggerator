require "loggerator"

module Loggerator
  module Namespace
    include Loggerator

    def self.included(mod)
      mod.extend self
    end

    def log(data={}, &block)
      log_namespace! do
        super
      end
    end

    def log_error(e, data={})
      log_namespace! do
        super
      end
    end

    private
      def log_namespace!(&block)
        log_context({ns: kind_of?(Module) ? name : self.class.name }, &block)
      end
  end
end
