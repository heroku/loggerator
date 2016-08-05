require 'sinatra'

# pathing built via docker-compose
require_relative './lib/loggerator'
require_relative './lib/loggerator/middleware/request_store'

include Loggerator

use Loggerator::Middleware::RequestStore

set :port, '3000'
set :bind, '0.0.0.0' # bind for docker
set :logging, false  # disable default logging

get '/' do
  context app: :basic do
    log method: :get do
      "Hello Loggerator!\n"
    end
  end
end
