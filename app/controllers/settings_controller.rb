class SettingsController < ApplicationController
  before_action :authenticate_user
  def index
    @user = current_user
    @current_user = current_user
    @notifications = current_user.notifications
    @sessions = @current_user.sessions.order(created_at: :desc)
  end
end