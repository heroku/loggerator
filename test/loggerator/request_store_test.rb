require 'minitest/autorun'
require 'logger'

require_relative '../../lib/loggerator'

class Loggerator::TestRequestStore < Minitest::Test
  def setup
    # flush request store
    Thread.current[:request_store] = {}

    @env = {
      'REQUEST_ID' => 'abc',
      'REQUEST_IDS' => %w[ abc def ]
    }
  end

  def test_seeds_request_id
    Loggerator::RequestStore.seed(@env)

    assert_equal 'abc,def', Loggerator::RequestStore.store[:request_id]
  end

  def test_seeds_log_context
    Loggerator::RequestStore.seed(@env)

    assert_equal 'abc,def', Loggerator::RequestStore.store[:log_context][:request_id]
  end

  def test_is_cleared_by_clear!
    Loggerator::RequestStore.seed(@env)
    Loggerator::RequestStore.clear!

    assert_nil Loggerator::RequestStore.store[:request_id]
  end
end
