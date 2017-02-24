require_relative "../test_helper"

class TestLoggeratorRails < Minitest::Test
  def test_middleware_modifications
    # This ensures that the middlewares list includes our middlewares and that
    # the default request id handler has been replaced.
    middlewares = Rails.application.middleware

    assert middlewares.include?(Loggerator::Middleware::RequestStore)
    assert middlewares.include?(Loggerator::Middleware::RequestID)
    refute middlewares.include?(ActionDispatch::RequestId)
  end

  def test_loggerator_included
    # This ensures that Loggerator has been included in each of the classes below
    # by checking to ensure that it's included in each classes "ancestors" list.
    [ ActionView::Base,
      ActiveRecord::Base,
      ActionMailer::Base,
      ActionController::Base
    ].each do |c|
      assert c.ancestors.include?(Loggerator)
    end
  end

  def test_log_subscriber_attached
    # This sets subscribers to a unique list of all log subscribers. Our
    # LogSubscriber class should be included in this list.
    subscribers = \
      ActiveSupport::Notifications.notifier
        .instance_variable_get("@subscribers")
        .map { |subscriber|
          subscriber.instance_variable_get("@delegate").class
        }.uniq

    assert subscribers.include?(Loggerator::Railtie::LogSubscriber)
  end

  def test_detach_existing_subscribers
    # This sets subscribed_classes to the unique list of classes contstants
    # which are currently subscribed to either "process_action.action_controller"
    # or "redirect_to.action_controller". Given that only our LogSubscriber
    # should be subscribed to these two events, only our LogSubscriber should
    # be in the resulting list.
    subscribed_classes = \
      ActiveSupport::Notifications.notifier
        .instance_variable_get("@subscribers")
        .map { |subscriber|
          subscriber.instance_variable_get("@delegate")
        }.select { |delegate|
          patterns = delegate.instance_variable_get("@patterns")
          patterns && (
            patterns.include?("process_action.action_controller") ||
            patterns.include?("redirect_to.action_controller")
          )
        }.map(&:class).uniq

    assert_equal subscribed_classes, [Loggerator::Railtie::LogSubscriber]
  end
end
