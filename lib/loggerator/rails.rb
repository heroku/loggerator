require "loggerator"
require "loggerator/rails/log_subscriber"

# Using LoggeratorRails namespace over Loggerator::Rails due to the fact that
# when Loggerator is included in Rails classes, e.g. ActiveRecord::Base,
# Loggerator::Rails takes precedence over the Rails namespace, causing things
# like "Rails.env" to break without prefixing "::". This is not only annoying,
# but could break existing projects which upgrade to this version of Loggerator.
module LoggeratorRails
  # Implementation respectfully borrowed from:
  # https://github.com/minefold/scrolls-rails
  extend self

  def setup(_app)
    detach_existing_subscribers
    LoggeratorRails::LogSubscriber.attach_to(:action_controller)
  end

  def subscribe?
    return true unless defined?(@@subscribe) # ensure default is true

    @@subscribe
  end

  def use_default_subscribers!
    @@subscribe = false
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

module Loggerator
  class Railtie < ::Rails::Railtie
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
      LoggeratorRails.setup(Rails.application) if LoggeratorRails.subscribe?
    end
  end
end
