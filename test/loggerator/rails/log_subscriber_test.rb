require_relative "../../test_helper"

class FakeEvent
  attr_accessor :payload
end

class LoggeratorRailsLogSubscriber < Minitest::Test
  def setup
    @sub = Loggerator::Rails::LogSubscriber.new
    @evt = FakeEvent.new
  end

  def test_process_action_with_array
    out, err = capture_subprocess_io do
      @evt.payload = {
        exception: ["Exception", "Test array"]
      }

      @sub.process_action(@evt)
    end

    assert_empty(out)
    assert_match(
      /status=500 exception class=Exception message=\"Test array\" exception_id=\d+\n$/,
      err
    )
  end

  def test_process_action_with_exception
    out, err = capture_subprocess_io do
      @evt.payload = {
        exception: Exception.new("Test exception")
      }

      @sub.process_action(@evt)
    end

    assert_empty(out)
    assert_match(
      /status=500 exception class=Exception message=\"Test exception\" exception_id=\d+\n$/,
      err
    )
  end
end
