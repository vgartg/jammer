class HomeController < ApplicationController
  def index
    @user = current_user
    @current_user = current_user
    if current_user
      @notifications = current_user.notifications
    end
  end
end