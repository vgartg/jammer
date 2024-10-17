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

  def oauth_callback
    session_code = params[:code]

    result = RestClient.post('https://github.com/login/oauth/access_token',
                             { client_id: ENV['GITHUB_CLIENT_ID'],
                               client_secret: ENV['GITHUB_CLIENT_SECRET'],
                               code: session_code },
                             accept: :json)

    access_token = JSON.parse(result)['access_token']

    user_response = RestClient.get('https://api.github.com/user',
                                   { authorization: "token #{access_token}" })
    user_data = JSON.parse(user_response)

    @user = User.find_or_create_by(github_id: user_data['id']) do |user|
      user.email = user_data['email']
      user.name = user_data['login']
    end

    session[:current_user] = @user.id
    redirect_to dashboard_path
  end


  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar, :background_image,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
                  :visibility, :jams_visibility, :theme)
  end
end