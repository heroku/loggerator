# like running `ruby -W0`
$VERBOSE = nil

require "rack/test"
require "minitest/mock"
require "minitest/autorun"
require "pry"
require "pp"

require "logger"

require "combustion"
Combustion.path = "test/internal"
Combustion.initialize! :all

# Unfreeze rails middleware
Rails.application.middleware.instance_variable_set(:@middlewares,
  Rails.application.middleware.instance_variable_get(:@middlewares).dup)

require "loggerator"
require "loggerator/rails"
