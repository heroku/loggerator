require "loggerator"

module Loggerator
  module Metrics
    include Loggerator
    extend self

    def count(key, value=1)
      log("count##{Loggerator.config.metrics_app_name}.#{key}" => value)
    end

    def sample(key, value)
      log("sample##{Loggerator.config.metrics_app_name}.#{key}" => value)
    end

    def unique(key, value)
      log("unique##{Loggerator.config.metrics_app_name}.#{key}" => value)
    end

    def measure(key, value, units="s")
      log("measure##{Loggerator.config.metrics_app_name}.#{key}" => "#{value}#{units}")
    end
  end

  # included Metrics shortcut
  def m; Metrics; end
end

# simple alias if its not already being used
Metrics = Loggerator::Metrics unless defined?(Metrics)
