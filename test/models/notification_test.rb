require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def setup
    @user_recipient = users(:recipient)
    @user_actor = users(:actor)
    @notification = Notification.new(
      recipient: @user_recipient,
      actor: @user_actor,
      action: "created",
      notifiable: @user_recipient
    )
  end

  def test_notification_validity
    assert @notification.valid?
  end

  def test_notification_without_recipient
    @notification.recipient = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:recipient_id], "can't be blank"
  end

  def test_notification_without_actor
    @notification.actor = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:actor_id], "can't be blank"
  end

  def test_notification_without_action
    @notification.action = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:action], "can't be blank"
  end

  def test_notification_without_notifiable
    @notification.notifiable = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:notifiable_id], "can't be blank"
  end

  def test_unread_scope
    read_notification = Notification.create!(recipient: @user_recipient, actor: @user_actor, action: "created", notifiable: @user_recipient, read: true)
    unread_notification = Notification.create!(recipient: @user_recipient, actor: @user_actor, action: "updated", notifiable: @user_recipient, read: false)

    assert_includes Notification.unread, unread_notification
    assert_not_includes Notification.unread, read_notification
  end
end