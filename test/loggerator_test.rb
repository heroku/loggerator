require 'minitest/autorun'
require 'logger'

require_relative '../lib/loggerator'

class TestLoggerator < Minitest::Test
  include Loggerator

  def setup
    # flush request store
    Thread.current[:request_store] = {}

    self.default_context = {}
  end

  def test_logs_in_structured_format
    out, err = capture_subprocess_io do
      log(foo: "bar", baz: 42)
    end

    assert_equal out, "foo=bar baz=42\n"
    assert_equal err, ''
  end

  def test_re_raises_errors
    assert_raises(RuntimeError) do
      capture_subprocess_io do
        log(foo: 'bar') { raise RuntimeError }
      end
    end
  end

  def test_supports_blocks_to_log_stages_and_elapsed
    out, _ = capture_subprocess_io do
      log(foo: 'bar') { }
    end

    assert_equal out, "foo=bar at=start\n" \
      + "foo=bar at=finish elapsed=0.000\n"
  end

  def test_merges_default_context_with_eq
    # testing both methods
    self.default_context = { app: 'my_app' }

    out, _ = capture_subprocess_io do
      log(foo: 'bar')
    end

    assert_equal out, "app=my_app foo=bar\n"
  end

  def test_suports_a_log_context
    out, _ = capture_subprocess_io do
      self.log_context(app: 'my_app') do
        log(foo: 'bar')
      end
    end

    assert_equal out, "app=my_app foo=bar\n"
  end

  def test_log_context_merged_with_default_context
    out, _ = capture_subprocess_io do
      self.default_context = { app: 'my_app' }
      self.log_context(foo: 'bar') do
        log(bah: 'boo')
      end
    end

    assert_equal out, "app=my_app foo=bar bah=boo\n"
  end
end
