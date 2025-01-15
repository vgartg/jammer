class UsersController < ApplicationController
  before_action :authenticate_user, only: %i[edit_user update_user destroy]
  before_action :require_subdomain, only: :frontpage

  def new
    return unless current_user

    redirect_to user_path(current_user.id)
  end

  def show
    @user = User.find(params[:id])
    @current_user = User.find_by_id(session[:current_user])
    return unless @current_user

    @friendship = @current_user.friendship_with(@user)
  end

  def index
    @pagy, @users = pagy(User.all, limit: 16)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @token = @user.set_email_confirm_token
      EmailConfirmMailer.with(user: @user, token: @token).email_confirm.deliver_later
      flash[:success] = 'Инструкции были отправлены на ваш адрес'
      redirect_to edit_email_confirm_url(user: { email_confirm_token: @user.email_confirm_token,
                                                 email: @user.email }).gsub('&amp;', '&')
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
        flash[:failure] = 'Current password is incorrect.'
        redirect_to settings_path
        return
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank? || params[:user][:current_password].blank?
        flash[:failure] = 'All fields must be filled in'
        redirect_to settings_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] = 'New password is too short (minimum is 5 characters).'
        redirect_to settings_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] = 'New passwords do not match.'
        redirect_to settings_path
        return
      elsif user_params[:password] == params[:user][:current_password]
        flash[:failure] = 'New password must be different from the old one.'
        redirect_to settings_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] = 'Successfully saved!'
      redirect_to settings_path
    else
      flash[:failure] = 'Something went wrong!'
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
                                   { Authorization: "token #{access_token}" })
    user_data = JSON.parse(user_response)

    @user = User.find_or_initialize_by(github_id: user_data['id']) do |user|
      user.email = user_data['email']
      user.name = user_data['login']

      # Генерируем временный пароль
      temp_password = SecureRandom.hex(16)
      user.password = temp_password
      user.password_confirmation = temp_password
    end

    if @user.new_record?
      if @user.save
        # Отправьте электронное письмо с подтверждением адреса и ссылкой на установку пароля
        PasswordResetMailer.with(user: @user).password_reset.deliver_later

        session[:current_user] = @user.id

        flash[:info] = "Вы успешно зарегистрировались! Проверьте свою почту, чтобы установить новый пароль."
        redirect_to dashboard_path # Переадресация на страницу с информацией
      else
        flash[:error] = 'Не удалось создать пользователя.'
        redirect_to login_path
      end
    else
      session[:current_user] = @user.id
      redirect_to dashboard_path
    end
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar, :background_image,
                  :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
                  :visibility, :jams_visibility, :theme)
  end
end
