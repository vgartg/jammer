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
      @notifications = current_user.notifications
      @friendship = @current_user.friendship_with(@user)
    end
  end

  def index
    @users = User.all
    if current_user
      @notifications = current_user.notifications
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:current_user] = @user.id
      browser_string = request.user_agent
      browser = UserAgent.parse(browser_string).browser
      Session.create_session(@user.id, session[:session_id], request.remote_ip, browser: browser)
      @user.update(last_seen_at: Time.zone.now)
      redirect_to dashboard_path
    else
      flash[:failure] = @user.errors.full_messages
      render :new, status: :see_other
    end
  end

  def destroy
    @user = current_user
    if @user.authenticate(params[:user][:password])
      @user.destroy
      flash[:success] = t 'users.destroy.success'
      render json: { success: true }, status: :ok
    else
      flash[:error] = t 'users.destroy.error'
      render json: { success: false, error: 'Неверный пароль.' }, status: :unprocessable_entity
    end
  end

  def edit_user
    @user = current_user
  end

  def update_user
    @user = current_user

    if user_params[:password].present? || user_params[:password_confirmation].present? || params[:user][:current_password].present?
      unless @user.authenticate(params[:user][:current_password])
        flash[:failure] = t 'users.update_user.failure1'
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank? || params[:user][:current_password].blank?
        flash[:failure] = t 'users.update_user.failure2'
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] = t 'users.update_user.failure3'
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] = t 'users.update_user.failure4'
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password] == params[:user][:current_password]
        flash[:failure] = t 'users.update_user.failure5'
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] = t 'users.update_user.success'
      redirect_to settings_path
    else
      flash[:failure] = t 'users.update_user.failure6'
      redirect_to settings_path
    end
  end

  def update_activity
    if current_user
      current_user.update(last_active_at: Time.current, visibility: params[:visibility])
      head :ok
    else
      head :unauthorized
    end
  end

  def frontpage
    subdomain = Subdomain.extract_subdomain(request)
    @user = User.find_by_link_username(subdomain)
    @current_user = current_user
    @notifications = current_user.notifications
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar, :background_image,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
                  :visibility, :jams_visibility, :theme)
  end
end