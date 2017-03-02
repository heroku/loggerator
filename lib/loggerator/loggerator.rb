require "loggerator/log"
require "loggerator/configuration"
require "loggerator/request_store"
require "loggerator/middleware"

module Loggerator
  def self.included(mod)
    mod.extend self
  end

  def self.config
    @config ||= Configuration.new

    return @config unless block_given?

    yield(@config)
  end

  def self.config=(cfg)
    @config = Configuration.new(cfg)
  end

  def log(data, &block)
    Log.to_stream(Log.stdout, Log.contexts(data), &block)
  end

  def log_error(e=$ERROR_INFO, data = {})
    exception_id = e.object_id

    # Log backtrace in reverse order for easier digestion.
    if e.backtrace
      e.backtrace.reverse.each do |backtrace|
        Log.to_stream(Log.stderr, Log.contexts(
          exception_id: exception_id,
          backtrace:    backtrace
        ))
      end
    end

    # then log the exception message last so that it's as close to the end of
    # a log trace as possible
    data.merge!(
      exception:    true,
      class:        e.class.name,
      message:      e.message,
      exception_id: exception_id
    )

    data[:status] = e.status if e.respond_to?(:status)

    Log.to_stream(Log.stderr, Log.contexts(data))
  end

  def log_context(data, &block)
    old = Log.local_context
    Log.local_context = old.merge(data)
    res = block.call
  ensure
    Log.local_context = old
    res
  end
end
