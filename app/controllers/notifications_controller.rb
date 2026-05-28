class NotificationsController < ApplicationController
  before_action :authenticate_user

  def index
    notifs = current_user.notifications.includes(:actor, :notifiable).order(created_at: :desc).to_a
    jcs = notifs.filter_map(&:notifiable).grep(JamContributor)
    ActiveRecord::Associations::Preloader.new(records: jcs, associations: :jam).call if jcs.any?
    @notifications = notifs
  end

  def show
    @notification = current_user.notifications.find(params[:id])
  end

  def mark_as_read
    current_user.notifications.where(read: false).update_all(read: true)
    render json: { ok: true }
  end
end
