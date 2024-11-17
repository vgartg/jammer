class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to user_path(current_user.id)
    end
  end

  def create
    user = User.find_by_email(auth_params[:email])
    browser_string = request.user_agent
    browser = UserAgent.parse(browser_string).browser
    if user.present? && user.authenticate(auth_params[:password])
      if user.email_confirmed
        session[:current_user] = user.id
        unless Session.all.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).exists?
          Session.create_session(user.id, session[:session_id], request.remote_ip, browser)
        end
        if params[:remember_me] == "1"
          remember(user)
        end
        redirect_to dashboard_path
      else
        @token = user.set_email_confirm_token
        EmailConfirmMailer.with(user: user, token: @token).email_confirm.deliver_later
        flash[:success] ||= []
        flash[:success] << 'Инструкции были отправлены на ваш адрес'
        redirect_to edit_email_confirm_url(user: { email_confirm_token: user.email_confirm_token,
                                                   email: user.email }).gsub('&amp;', '&')
      end
    else
      flash[:failure] ||= []
      flash[:failure] << "Invalid email or password"
      redirect_to login_path
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
      flash[:success] ||= []
      flash[:success] << "Successfully logged out of other sessions"
      redirect_to settings_path
    else
      flash[:failure] ||= []
      flash[:failure] << "Invalid password"
      redirect_to settings_path
    end
  end

  private

  def auth_params
    params.permit(:email, :password, :remember_me)
  end
end