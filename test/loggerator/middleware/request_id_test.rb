require 'rack/test'
require 'minitest/mock'
require 'minitest/autorun'
require 'logger'

require_relative '../../../lib/loggerator'

class Loggerator::Middleware::TestRequestID < Minitest::Test
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Rack::Lint
      use Loggerator::Middleware::RequestID

      run ->(env) { [ 200, { }, [ 'hi' ] ] }
    end
  end

  def test_sets_request_id
    get '/'

    assert_match ::Loggerator::Middleware::RequestID::UUID_PATTERN,
      last_request.env['REQUEST_ID']
  end

  def test_sets_request_ids
    get '/'

    assert_match ::Loggerator::Middleware::RequestID::UUID_PATTERN,
      last_request.env['REQUEST_IDS'].first
  end
end
