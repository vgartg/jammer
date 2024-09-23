class NotificationsController < ApplicationController
  before_action :authenticate_user

  def index
    @notifications = current_user.notifications

    actions = {
      'accepted_friendship' => 'принял заявку в друзья',
      'sent_friend_request' => 'отправил запрос в друзья'
    }

    @notification.action = actions[@notification.action] || @notification.action
  end

  def show
    @notification = Notification.find(params[:id])

    actions = {
      'accepted_friendship' => 'принял заявку в друзья',
      'sent_friend_request' => 'отправил запрос в друзья'
    }

    @notification.action = actions[@notification.action] || @notification.action
  end

  def mark_as_read
    @notifications = current_user.notifications.where(read: false)
    @notifications.update_all(read: true)
    render json: @notifications
  end
end
