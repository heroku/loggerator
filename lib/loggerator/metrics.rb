require "loggerator"

module Loggerator
  module Metrics
    include Loggerator
    extend self

    Loggerator.config.metrics_app_name ||= "loggerator"

    def name=(name)
      Loggerator.config.metrics_app_name = name
    end

    def name
      Loggerator.config.metrics_app_name
    end

    def count(key, value=1)
      log("count##{name}.#{key}" => value)
    end

    def sample(key, value)
      log("sample##{name}.#{key}" => value)
    end

    def unique(key, value)
      log("unique##{name}.#{key}" => value)
    end

    def measure(key, value, units="s")
      log("measure##{name}.#{key}" => "#{value}#{units}")
    end
  end

  # included Metrics shortcut
  def m; Metrics; end
end

# simple alias if its not already being used
Metrics = Loggerator::Metrics unless defined?(Metrics)
