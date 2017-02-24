module Loggerator
  module Railtie
    class Adapter < ::Rails::Railtie
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

      config.after_initialize do
        Loggerator::Railtie::Helper.setup(Rails.application) if Loggerator::Railtie::Helper.subscribe?
      end
    end
  end
end
