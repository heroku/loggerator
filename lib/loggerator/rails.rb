require_relative "loggerator"

module Loggerator
  class Railtie < Rails::Railtie

    config.before_configuration do
      Rails.application.middleware.insert_after ActionDispatch::RequestId, Loggerator::Middleware::RequestStore
      Rails.application.middleware.swap         ActionDispatch::RequestId, Loggerator::Middleware::RequestID
    end

    config.before_initialize do
      [ ActionView::Base,
        ActiveRecord::Base,
        ActionMailer::Base,
        ActionController::Base ].each do |c|

        c.include Loggerator
      end
    end

  end
end
