module Loggerator
  # Don't expose internals into included modules so name-collisions are reduced
  module Log
    extend self

    def local_context
      RequestStore.store[:local_context] ||= {}
    end

    def local_context=(h)
      RequestStore.store[:local_context] = h
    end

    def stdout=(stream)
      Loggerator.config.stdout = stream
    end

    def stdout
      Loggerator.config.stdout
    end

    def stderr=(stream)
      Loggerator.config.stderr = stream
    end

    def stderr
      Loggerator.config.stderr
    end

    def contexts(data)
      Loggerator.config.default_context.merge(request_context.merge(local_context.merge(data)))
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
