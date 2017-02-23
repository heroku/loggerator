require_relative "../../test_helper"

class FakeEvent
  attr_accessor :payload
end

# mock Loggerator to something useful for this test
module Loggerator
  class << self
    def log_exception log, ex
      @@log = log
      @@ex = ex
    end

    def log
      @@log
    end

    def exception
      @@ex
    end
  end
end

class LoggeratorRailsLogSubscriber < Minitest::Test
  def setup
    @sub = Loggerator::Rails::LogSubscriber.new
    @evt = FakeEvent.new
  end

  def test_process_action_with_array
    @evt.payload = {
      exception: ["Exception", "Test array"]
    }

    @sub.process_action(@evt)

    assert_equal({status: 500}, Loggerator.log)
    assert_kind_of(Exception, Loggerator.exception)
    assert_equal("Test array", Loggerator.exception.message)
  end

  def test_process_action_with_exception
    @evt.payload = {
      exception: Exception.new("Test exception")
    }

    @sub.process_action(@evt)

    assert_equal({status: 500}, Loggerator.log)
    assert_kind_of(Exception, Loggerator.exception)
    assert_equal("Test exception", Loggerator.exception.message)
  end
end
