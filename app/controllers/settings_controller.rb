class SettingsController < ApplicationController
  before_action :authenticate_user
  def index
    @user = current_user
    @current_user = current_user
  end
end
