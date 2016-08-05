require 'sinatra'

# pathing built via docker-compose
require_relative './lib/loggerator'
require_relative './lib/loggerator/middleware/request_store'

use Loggerator::Middleware::RequestStore

set :port, '3000'
set :bind, '0.0.0.0' # bind for docker
set :logging, false  # disable default logging

include Loggerator

# Set Loggerator default_context
self.default_context = { app: :basic }

get '/' do
  context method: :get do
    log status: 200 do
      "Hello Loggerator!\n"
    end
  end
end
