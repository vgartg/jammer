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
    @friendships = @user.friendships.where(status: 'accepted') + @user.inverse_friendships.where(status: 'accepted')
    @received_requests = @user.inverse_friendships.where(status: 'pending')
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
      @token = @user.set_email_confirm_token
      EmailConfirmMailer.with(user: @user, token: @token).email_confirm.deliver_later
      flash[:success] ||= []
      flash[:success] << 'Инструкции были отправлены на ваш адрес'
      redirect_to edit_email_confirm_url(user: { email_confirm_token: @user.email_confirm_token,
                                                 email: @user.email }).gsub('&amp;', '&')
    else
      flash[:failure] ||= []
      flash[:failure].concat(@user.errors.full_messages)
      redirect_to register_path
    end
  end

  def destroy
    @user = current_user
    if @user.authenticate(params[:user][:password])
      @user.destroy
      flash[:success] ||= []
      flash[:success] << 'Аккаунт успешно удален.'
      render json: { success: true }, status: :ok
    else
      flash[:error] = 'Неверный пароль.'
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
        flash[:failure] ||= []
        flash[:failure] << "Current password is incorrect."
        redirect_to settings_path
        return
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank? || params[:user][:current_password].blank?
        flash[:failure] ||= []
        flash[:failure] << "All fields must be filled in"
        redirect_to settings_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] ||= []
        flash[:failure] << "New password is too short (minimum is 5 characters)."
        redirect_to settings_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] ||= []
        flash[:failure] << "New passwords do not match."
        redirect_to settings_path
        return
      elsif user_params[:password] == params[:user][:current_password]
        flash[:failure] ||= []
        flash[:failure] << "New password must be different from the old one."
        redirect_to settings_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] ||= []
      flash[:success] << "Successfully saved!"
      redirect_to settings_path
    else
      flash[:failure] ||= []
      flash[:failure] << "Something went wrong!"
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