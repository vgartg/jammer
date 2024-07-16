class UsersController < ApplicationController
  before_action :authenticate_user, only: [:edit_user, :update_user]
  def new

  end

  def show
    @user = User.find(params[:id])
    @current_user = User.find_by_id(session[:current_user])
  end

  def all_users
    @users = User.all
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:current_user] = user.id
      redirect_to dashboard_path
    else
      redirect_to register_path
    end
  end

  def edit_user
    @user = User.find(session[:current_user])
  end

  def update_user
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_profile_path(@user)
    else
      render :edit_user
    end
  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :status, :real_name, :location, :birthday, :phone_number)
  end
end