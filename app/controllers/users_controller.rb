class UsersController < ApplicationController
  before_action :authenticate_user, only: [:edit_user, :update_user, :destroy]
  before_action :require_subdomain, only: :frontpage
  def new
    if current_user
      redirect_to user_path(current_user.id)
    end
  end

  def show
    @user = User.find(params[:id])
    @current_user = User.find_by_id(session[:current_user])
    if @current_user
      @friendship = @current_user.friendship_with(@user)
      end
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:current_user] = @user.id
      @user.update(last_seen_at: Time.zone.now)
      redirect_to dashboard_path
    else
      flash[:errors] = @user.errors.full_messages
      render :new, status: :see_other
    end
  end

  def destroy
    @user = current_user
    @user.destroy
    redirect_to register_path
  end

  def edit_user
    @user = current_user
  end

  def update_user
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "Successfully saved!"
    else
      render :edit_user
    end
  end

  def update_activity
    if current_user
      current_user.update(last_active_at: Time.current)
      head :ok
    else
      head :unauthorized
    end
  end

  def frontpage

  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username)
  end
end