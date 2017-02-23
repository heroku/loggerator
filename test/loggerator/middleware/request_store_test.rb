require_relative "../../test_helper"

class Loggerator::Middleware::TestRequestStore < Minitest::Test
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Rack::Lint
      use Loggerator::Middleware::RequestStore

      run ->(env) { [ 200, { }, [ "hi" ] ] }
    end
  end

  def test_clears_the_store
    Thread.current[:request_store] = { something_added_before: "bar" }

    get "/"

    assert_nil Thread.current[:request_store][:something_added_before]
  end

  def test_seeds_the_store
    Thread.current[:request_store] = {}

    get "/"

    assert_equal Thread.current[:request_store], {
      request_id: nil,
      request_context: {
        request_id: nil
      }
    }
  end
end
