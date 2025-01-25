class SessionsController < ApplicationController
  def new
    return unless current_user
    redirect_to user_path(current_user.id)
  end

  def create
    user = User.find_by_email(auth_params[:email])
    browser_string = request.user_agent
    browser = UserAgent.parse(browser_string).browser
    if user.present? && user.authenticate(auth_params[:password])
      if user.email_confirmed
        session[:current_user] = user.id
        unless Session.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).exists?
          Session.create_session(user.id, session[:session_id], request.remote_ip, browser)
        end
        remember(user) if params[:remember_me] == '1'
        redirect_to dashboard_path
      elsif !user.email_confirm_period_valid? && user.last_active_at.nil? && user.last_seen_at.nil?
        user.destroy
        flash[:failure] =
          'Ваш аккаунт был удален из-за истечения срока действия токена. Пожалуйста, зарегистрируйтесь снова.'
        redirect_to login_path
      else
        if user.email_confirm_period_valid?
          flash[:success] = 'Письмо с кодом для входа уже было отправлено на вашу почту'
        else
          @token = user.set_email_confirm_token
          EmailConfirmMailer.with(user: user, token: @token).email_confirm.deliver_later
          flash[:success] = 'Инструкции были отправлены на ваш адрес'
        end
        redirect_to edit_email_confirm_url(user: { email_confirm_token: user.email_confirm_token,
                                                   email: user.email }).gsub('&amp;', '&')
      end
    else
      flash[:failure] = ['Invalid email or password']
      render :new, status: :see_other
    end
  end

  def destroy
    forget(current_user)
    current_session = Session.find_by(session_id: session[:session_id])
    current_session.destroy if current_session
    session[:current_user] = nil
    redirect_to root_path
  end

  def remember(user)
    user.remember_me
    cookies.encrypted.permanent[:remember_token] = user.remember_token
    cookies.encrypted.permanent[:current_user] = user.id
  end

  def forget(user)
    user.forget_me
    cookies.delete :remember_token
    cookies.delete :current_user
  end

  def logout_other_sessions
    if current_user && current_user.authenticate(params[:password])
      current_user.invalidate_other_sessions(session[:session_id])
      current_user.forget_me
      flash[:success] = 'Successfully logged out of other sessions'
      redirect_to settings_path
    else
      flash[:failure] = 'Invalid password'
      redirect_to settings_path
    end
  end

  def logout_all_sessions
    user = User.find(params[:user])
    session_ids = user.sessions.pluck(:id)
    if user.sessions.destroy_all
      flash[:success] = 'Все сессии успешно удалены'
      if user != current_user
        create_administration_record(current_user, user, { 'session_ids' => session_ids },
                                     'delete')
      end
    else
      flash[:failure] = 'Не удалось удалить сессии'
    end
    redirect_to edit_admin_user_path(user)
  end

  def logout_one_session
    user = User.find(params[:user])
    session = Session.find(params[:session_id])
    user_session = user.sessions.find_by(id: session.id)
    if user_session&.destroy
      flash[:success] = 'Сессия успешно удалена'
      create_administration_record(current_user, user, { 'session_id' => session.id }, 'delete') if user != current_user
    else
      flash[:failure] = 'Не удалось удалить сессию'
    end
    redirect_to edit_admin_user_path(user)
  end

  def omniauth
    auth = request.env['omniauth.auth']
    user = User.find_or_initialize_by(provider: auth['provider'], uid: auth['uid'])

    browser_string = request.user_agent
    browser = UserAgent.parse(browser_string).browser

    if user.persisted?
      session[:current_user] = user.id
      unless Session.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).exists?
        Session.create_session(user.id, session[:session_id], request.remote_ip, browser)
      end
      flash[:success] = "Вы успешно вошли через #{auth['provider'].capitalize}!"
      redirect_to dashboard_path
    else
      create_user_from_omniauth(user, auth)
    end
  end

  def create_user_from_omniauth(user, auth)
    temp_password = SecureRandom.hex(16)
    user.assign_attributes(
      name: auth['info']['name'] || auth['info']['nickname'],
      email: auth['info']['email'],
      password: temp_password,
      password_confirmation: temp_password
    )

    if user.save
      TemporaryPasswordMailer.temporary_password_email(user, temp_password).deliver_later
      session[:current_user] = user.id
      Session.create_session(user.id, session[:session_id], request.remote_ip, UserAgent.parse(request.user_agent).browser)
      flash[:success] = "Вы успешно зарегистрировались через #{auth['provider'].capitalize}!"
      redirect_to dashboard_path
    else
      flash[:failure] = user.errors.full_messages.to_sentence
      redirect_to login_path
    end
  end

  def failure
    flash[:failure] = "Авторизация через провайдера не удалась. Попробуйте снова."
    redirect_to login_path
  end

  private

  def auth_params
    params.permit(:email, :password, :remember_me)
  end
end
