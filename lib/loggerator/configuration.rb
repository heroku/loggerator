module Loggerator
  class Configuration
    attr_accessor :default_context, :metrics_app_name, :rails_default_subscribers, :stdout, :stderr

    def initialize(h = {})
      @default_context           = h[:default_context]           || {}
      @rails_default_subscribers = h[:rails_default_subscribers] || false
      @metrics_app_name          = h[:metrics_app_name]          || "loggerator"

      @stdout = h[:stdout] || $stdout
      @stderr = h[:stderr] || $stderr
    end

    def to_h
      {
        default_context: default_context,
        metrics_app_name: metrics_app_name,
        rails_default_subscribers: rails_default_subscribers
      }
    end
  end
end
