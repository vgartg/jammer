class PasswordResetsController < ApplicationController
  before_action :require_no_authentication
  before_action :check_user_params, only: %i[edit update]
  before_action :set_user, only: %i[edit update]

  def create
    user = User.find_by_email(params[:email])
    if user.present?
      token = user.set_password_reset_token
      PasswordResetMailer.with(user: user, token: token, locale: I18n.locale).reset_email.deliver_later
    end

    flash[:success] ||= []
    flash[:success] << t('controllers.password_resets.instructions_sent')
    redirect_to login_path
  end

  def edit; end

  def update
    failure = password_validation_failure
    if failure
      flash[:failure] ||= []
      flash[:failure] << failure
      redirect_to edit_password_reset_path(user: { email: @user.email, password_reset_token: @password_reset_token })
      return
    end

    if @user.update(user_params)
      flash[:success] ||= []
      flash[:success] << t('controllers.password_resets.success')
      redirect_to login_path
    else
      flash[:failure] ||= []
      flash[:failure] << t('controllers.password_resets.failure')
      redirect_to login_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def check_user_params
    return if params[:user].present?

    flash[:failure] ||= []
    flash[:failure] << t('controllers.password_resets.failure')
    redirect_to(login_path)
  end

  def set_user
    token = params.dig(:user, :password_reset_token)
    email = params.dig(:user, :email)
    user = User.find_by(email: email) if email.present?

    if user && token.present? && user.authenticate_password_reset_token(token) && user.password_reset_period_valid?
      @user = user
      @password_reset_token = token
    else
      flash[:failure] ||= []
      flash[:failure] << t('controllers.password_resets.invalid_token')
      redirect_to login_path
    end
  end

  def password_validation_failure
    pw = user_params[:password]
    confirmation = user_params[:password_confirmation]
    current = params.dig(:user, :current_password)

    return t('controllers.password_resets.fields_blank') if pw.blank? || confirmation.blank?
    return t('controllers.password_resets.too_short') if pw.length < 5
    return t('controllers.password_resets.no_match') if pw != confirmation
    return t('controllers.password_resets.same_as_old') if current.present? && pw == current

    nil
  end
end
