require_relative 'loggerator'

module Loggerator
  module Metrics
    include Loggerator
    extend self

    @@metrics_name = 'loggerator'

    def self.included(mod)
      mod.extend self
    end

    def name=(name)
      @@metrics_name = name
    end

    def name
      @@metrics_name
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

    def measure(key, value, units='s')
      log("measure##{name}.#{key}" => "#{value}#{units}")
    end
  end

  # included Metrics shortcut
  def m; Metrics; end
end

# simple alias if its not already being used
Metrics = Loggerator::Metrics unless defined?(Metrics)
