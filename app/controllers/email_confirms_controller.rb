class EmailConfirmsController < ApplicationController
  before_action :check_params, only: [:update]
  before_action :set_user_by_email, only: [:edit]
  before_action :set_user, only: [:update]

  def edit; end

  def update
    if @user.update(email_confirmed: true)
      browser = UserAgent.parse(request.user_agent).browser

      locale = session[:locale]
      reset_session
      session[:locale] = locale if locale.present?
      session[:current_user] = @user.id

      Session.where(user_id: @user.id, ip_address: request.remote_ip, browser: browser).destroy_all
      Session.create_session(@user.id, session[:session_id], request.remote_ip, browser)

      remember(@user) if params[:remember_me] == '1'
      flash[:success] ||= []
      flash[:success] << t('email_confirms.update.success')
      redirect_to dashboard_path
    else
      flash[:failure] ||= []
      flash[:failure] << t('email_confirms.update.failure')
      redirect_to register_path
    end
  end

  private

  def check_params
    return if params.dig(:user, :code).present?

    flash[:failure] ||= []
    flash[:failure] << t('email_confirms.update.code_blank')
    redirect_to edit_email_confirm_path(user: { email: params.dig(:user, :email) })
  end

  def set_user_by_email
    email = params.dig(:user, :email)
    if email.blank?
      redirect_to register_path
      return
    end

    @user = User.find_by(email: email) || User.new(email: email)
  end

  def set_user
    email = params.dig(:user, :email)
    code = params.dig(:user, :code)
    user = User.find_by(email: email) if email.present?

    if user && user.authenticate_email_confirm_token(code) && user.email_confirm_period_valid?
      @user = user
    else
      flash[:failure] ||= []
      flash[:failure] << t('email_confirms.update.invalid_code')
      redirect_to edit_email_confirm_path(user: { email: email })
    end
  end
end
