class NotificationsController < ApplicationController
  before_action :authenticate_user

  def index
    @notifications = current_user.notifications
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def mark_as_read
    current_user.notifications.where(read: false).update_all(read: true)
    head :no_content
  end
end
