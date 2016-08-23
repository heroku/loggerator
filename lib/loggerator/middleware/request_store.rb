module Loggerator::Middleware
  class RequestStore
    def initialize(app, options={})
      @app = app
      @store = options[:store] || Loggerator::RequestStore
    end

    def call(env)
      @store.clear!
      @store.seed(env)
      @app.call(env)
    end
  end
end
