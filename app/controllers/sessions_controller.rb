class SessionsController < ApplicationController
  before_action :authenticate_user, only: %i[logout_other_sessions logout_all_sessions logout_one_session]
  before_action :admin?, only: %i[logout_all_sessions logout_one_session]

  def new
    return unless current_user

    redirect_to user_path(current_user.id)
  end

  def create
    user = User.find_by_email(auth_params[:email])
    browser = UserAgent.parse(request.user_agent).browser

    unless user.present? && user.authenticate(auth_params[:password])
      flash[:failure] ||= []
      flash[:failure] << t('sessions.create.failure')
      redirect_to login_path
      return
    end

    unless user.email_confirmed
      if user.email_confirm_period_valid?
        flash[:success] = t('controllers.sessions.email_letter_sent')
      else
        token = user.set_email_confirm_token
        EmailConfirmMailer.with(user: user, token: token, locale: I18n.locale).email_confirm.deliver_later
        flash[:success] ||= []
        flash[:success] << t('controllers.sessions.instructions_sent')
      end
      redirect_to edit_email_confirm_path(user: { email: user.email })
      return
    end

    locale = session[:locale]
    reset_session
    session[:locale] = locale if locale.present?
    session[:current_user] = user.id

    Session.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).destroy_all
    Session.create_session(user.id, session[:session_id], request.remote_ip, browser)

    remember(user) if params[:remember_me] == '1'
    redirect_to dashboard_path
  end

  def destroy
    forget(current_user) if current_user
    current_session = Session.find_by(session_id: session[:session_id])
    current_session&.destroy
    reset_session
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
    if current_user && (current_user.oauth_user? || current_user.authenticate(params[:password]))
      current_user.invalidate_other_sessions(session[:session_id])
      current_user.forget_me
      flash[:success] ||= []
      flash[:success] << t('sessions.logout_other_sessions.success')
      redirect_to settings_path
    else
      flash[:failure] ||= []
      flash[:failure] << t('sessions.logout_other_sessions.failure')
      redirect_to settings_path
    end
  end

  def logout_all_sessions
    user = User.find(params[:user])
    session_ids = user.sessions.pluck(:id)
    if user.sessions.destroy_all
      flash[:success] = t('controllers.sessions.all_sessions_logged_out')
      if user != current_user
        create_administration_record(current_user, user, { 'session_ids' => session_ids },
                                     'delete')
      end
    else
      flash[:failure] = t('controllers.sessions.sessions_logout_failed')
    end
    redirect_to edit_admin_user_path(user)
  end

  def logout_one_session
    user = User.find(params[:user])
    user_session = user.sessions.find_by(id: params[:session_id])

    if user_session&.destroy
      flash[:success] = t('controllers.sessions.session_logged_out')
      create_administration_record(current_user, user, { 'session_id' => user_session.id }, 'delete') if user != current_user
    else
      flash[:failure] = t('controllers.sessions.session_logout_failed')
    end
    redirect_to edit_admin_user_path(user)
  end

  private

  def auth_params
    params.permit(:email, :password, :remember_me)
  end
end
