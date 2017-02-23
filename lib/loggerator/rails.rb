require_relative "loggerator"
require_relative "rails/log_subscriber"

module Loggerator
  module Rails
    extend self

    def setup(_app)
      detach_existing_subscribers
      Loggerator::Rails::LogSubscriber.attach_to(:action_controller)
    end

    def detach_existing_subscribers
      ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
        case subscriber
        when ActionView::LogSubscriber
          unsubscribe(:action_view, subscriber)
        when ActionController::LogSubscriber
          unsubscribe(:action_controller, subscriber)
        end
      end
    end

    def unsubscribe(component, subscriber)
      events = events_for_subscriber(subscriber)

      events.each do |event|
        notifier = ActiveSupport::Notifications.notifier
        notifier.listeners_for("#{event}.#{component}").each do |listener|
          if listener.instance_variable_get('@delegate') == subscriber
            ActiveSupport::Notifications.unsubscribe(listener)
          end
        end
      end
    end

    def events_for_subscriber(subscriber)
      subscriber.public_methods(false).reject {|method| method.to_s == 'call' }
    end
  end

  class Railtie < ::Rails::Railtie
    config.before_configuration do
      ::Rails.application.middleware.insert_after ActionDispatch::RequestId, Loggerator::Middleware::RequestStore
      ::Rails.application.middleware.swap         ActionDispatch::RequestId, Loggerator::Middleware::RequestID
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
      Loggerator::Rails.setup(::Rails.application)
    end
  end
end
