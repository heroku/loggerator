require_relative "../test_helper"
require "loggerator/metrics"

class TestLoggeratorMetrics < Minitest::Test
  include Loggerator
  include Loggerator::Metrics

  def config
    Loggerator.config
  end

  def test_name_equals
    self.name = "test_name_equals"

    assert_equal "test_name_equals", config.metrics_app_name
  end

  def test_name
    config.metrics_app_name = "test_name"

    assert_equal "test_name", self.name
  end

  def test_count
    config.metrics_app_name = "test_count"
    out, err = capture_subprocess_io do
      self.count(:foo, 99)
    end

    assert_empty err
    assert_match(/count#test_count\.foo=99/, out)
  end

  def test_sample
    config.metrics_app_name = "test_sample"
    out, err = capture_subprocess_io do
      self.sample(:foo, :bar)
    end

    assert_empty err
    assert_match(/sample#test_sample\.foo=bar/, out)
  end

  def test_unique
    config.metrics_app_name = "test_unique"
    out, err = capture_subprocess_io do
      self.unique(:foo, :bar)
    end

    assert_empty err
    assert_match(/unique#test_unique\.foo=bar/, out)
  end

  def test_measure
    config.metrics_app_name = "test_measure"
    out, err = capture_subprocess_io do
      self.measure(:foo, 60, "ms")
    end

    assert_empty err
    assert_match(/measure#test_measure\.foo=60ms/, out)
  end
end

