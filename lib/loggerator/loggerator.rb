require "loggerator/request_store"
require "loggerator/middleware"

module Loggerator

  def self.included(mod)
    mod.extend self
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

  # Don't expose internals into included modules so name-collisions are reduced
  module Log
    extend self

    def default_context=(default_context)
      @@default_context = default_context
    end

    def default_context
      @@default_context ||= {}
    end

    def local_context
      RequestStore.store[:local_context] ||= {}
    end

    def local_context=(h)
      RequestStore.store[:local_context] = h
    end

    def stdout=(stream)
      @@stdout = stream
    end

    def stdout
      @@stdout ||= $stdout
    end

    def stderr=(stream)
      @@stderr = stream
    end

    def stderr
      @@stderr ||= $stderr
    end

    def contexts(data)
      default_context.merge(request_context.merge(local_context.merge(data)))
    end

    def to_stream(stream, data, &block)
      unless block
        str = unparse(data)
        stream.print(str + "\n")
      else
        data = data.dup
        start = Time.now
        to_stream(stream, data.merge(at: 'start'))
        begin
          res = yield

          to_stream(stream, data.merge(
            at: 'finish', elapsed: (Time.now - start).to_f))
          res
        rescue
          to_stream(stream, data.merge(
            at: 'exception', elapsed: (Time.now - start).to_f))
          raise $!
        end
      end
    end

    private
      def request_context
        RequestStore.store[:request_context] || {}
      end

      def unparse(attrs)
        attrs.map { |k, v| unparse_pair(k, v) }.compact.join(" ")
      end

      def unparse_pair(k, v)
        v = v.call if v.is_a?(Proc)
        # only quote strings if they include whitespace
        if v == nil
          nil
        elsif v == true
          k
        elsif v.is_a?(Float)
          "#{k}=#{format("%.3f", v)}"
        elsif v.is_a?(String) && v =~ /\s/
          quote_string(k, v)
        elsif v.is_a?(Time)
          "#{k}=#{v.iso8601}"
        else
          "#{k}=#{v}"
        end
      end

      def quote_string(k, v)
        # try to find a quote style that fits
        if !v.include?('"')
          %{#{k}="#{v}"}
        elsif !v.include?("'")
          %{#{k}='#{v}'}
        else
          %{#{k}="#{v.gsub(/"/, '\\"')}"}
        end
      end
  end
end
