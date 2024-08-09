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

    if user_params[:password].present? || user_params[:password_confirmation].present? || params[:user][:current_password].present?
      unless @user.authenticate(params[:user][:current_password])
        flash[:failure] = "Current password is incorrect."
        # render :edit_user, status: :see_other
        redirect_to dashboard_path
        return
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank? || params[:user][:current_password].blank?
        flash[:failure] = "All fields must be filled in"
        # render :edit_user, status: :see_other
        redirect_to dashboard_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] = "New password is too short (minimum is 5 characters)."
        # render :edit_user, status: :see_other
        redirect_to dashboard_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] = "New passwords do not match."
        # render :edit_user, status: :see_other
        redirect_to dashboard_path
        return
      elsif user_params[:password] == params[:user][:current_password]
        flash[:failure] = "New password must be different from the old one."
        # render :edit_user, status: :see_other
        redirect_to dashboard_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] = "Successfully saved!"
      redirect_to dashboard_path
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
    subdomain = Subdomain.extract_subdomain(request)
    @user = User.find_by_link_username(subdomain)
  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username)
  end
end