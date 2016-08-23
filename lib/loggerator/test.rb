module Loggerator
  alias_method :log_on,       :log
  alias_method :log_error_on, :log_error

  def log_off(data, &block)
    block.call if block
  end

  def log_error_off(e, data={}, &block)
    block.call if block
  end

  class << self
    @@log_switch = true

    def turn_log(on_or_off)
      return unless %i[on off].include?(on_or_off.to_sym)
      alias_method :log,       :"log_#{on_or_off}"
      alias_method :log_error, :"log_error_#{on_or_off}"
      @@log_switch = on_or_off.to_sym == :on
    end

    def log?
      @@log_switch
    end
  end

end

unless ENV.has_key?("TEST_LOGS")
  Loggerator.turn_log(:off)
end
