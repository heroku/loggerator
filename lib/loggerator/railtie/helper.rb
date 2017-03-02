module Loggerator
  module Railtie
    module Helper
      # Implementation respectfully borrowed from:
      # https://github.com/minefold/scrolls-rails
      extend self

      def setup(_app)
        return unless subscribe?

        detach_existing_subscribers
        Loggerator::Railtie::LogSubscriber.attach_to(:action_controller)
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

      def subscribe?
        !Loggerator.config.rails_default_subscribers
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
  end
end
