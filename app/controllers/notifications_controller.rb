class NotificationsController < ApplicationController
  before_action :authenticate_user

  def index
    @notifications = fetch_notifications(current_user)
  end

  def show
    @notification = current_user.notifications.find(params[:id])
  end

  def mark_as_read
    current_user.notifications.where(read: false).update_all(read: true)
    render json: { ok: true }
  end
end
