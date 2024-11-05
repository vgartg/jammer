class AdminsController < ApplicationController
  before_action :admin?
  def index
    if current_user
      @notifications = current_user.notifications
    end
  end
end