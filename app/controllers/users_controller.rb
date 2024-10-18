class UsersController < ApplicationController
  before_action :authenticate_user, only: [:edit_user, :update_user, :destroy]
  before_action :require_subdomain, only: :frontpage

  def new
    if current_user
      redirect_to user_path(current_user.id)
    end

    @client_id = ENV['GITHUB_CLIENT_ID']
    render :new, locals: { client_id: @client_id }
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
    if request.query_parameters.present?
      auth_data = request.env['omniauth.auth']
      name_ = auth_data['info']['name'] || auth_data['info']['nickname']
      email_ = auth_data['info']['email']
      provider_ = auth_data['provider']

      if name_.present? && email_.present? && provider_.present?
        @user = User.new(
          name: name_,
          email: email_,
          auth_via: provider_
        )
        @user.validate_password = false

        if @user.save
          session[:current_user] = @user.id
          browser_string = request.user_agent
          browser = UserAgent.parse(browser_string).browser
          Session.create_session(@user.id, session[:session_id], request.remote_ip, browser: browser)
          @user.update(last_seen_at: Time.zone.now)
          redirect_to dashboard_path
        else
          puts @user.errors.full_messages
          flash[:failure] = @user.errors.full_messages
          redirect_to register_path
        end
      end
    else
      @user = User.new(user_params)
      @user.validate_password = true
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
  end

  def destroy
    @user = current_user
    if @user.authenticate(params[:user][:password])
      @user.destroy
      flash[:success] = 'Аккаунт успешно удален.'
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
        flash[:failure] = "Current password is incorrect."
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank? || params[:user][:current_password].blank?
        flash[:failure] = "All fields must be filled in"
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] = "New password is too short (minimum is 5 characters)."
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] = "New passwords do not match."
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      elsif user_params[:password] == params[:user][:current_password]
        flash[:failure] = "New password must be different from the old one."
        # render :edit_user, status: :see_other
        redirect_to settings_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] = "Successfully saved!"
      redirect_to settings_path
    else
      flash[:failure] = "Something went wrong!"
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

  # def oauth_callback
  #   auth_hash = request.env['omniauth.auth']
  #   @user = User.find_or_create_by(github_id: auth_hash['uid']) do |user|
  #     user.email = auth_hash['info']['email'] || "default-email@example.com"
  #     user.name = auth_hash['info']['name']
  #   end
  #   session[:current_user] = @user.id
  #   redirect_to dashboard_path
  # end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar, :background_image,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
                  :visibility, :jams_visibility, :theme, :auth_via, :social_id)
  end
end