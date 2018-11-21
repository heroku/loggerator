module Loggerator
  module Railtie
    class Adapter < ::Rails::Railtie
      config.before_configuration do
        Rails.application.middleware.insert_after ActionDispatch::RequestId, Loggerator::Middleware::RequestStore
        Rails.application.middleware.swap         ActionDispatch::RequestId, Loggerator::Middleware::RequestID

        Rails.application.middleware.delete(Rails::Rack::Logger) if defined?(Rails::Rack::Logger)
      end

      config.before_initialize do
        %w[ ActionView::Base
            ActiveRecord::Base
            ActionMailer::Base
            ActionController::Base ].each do |c|
          begin
            base_class = Module.const_get(c)
            base_class.include Loggerator
          rescue NameError
          end
        end
      end

      config.after_initialize do
        Loggerator::Railtie::Helper.setup(Rails.application)
      end
    end
  end
end
