class PasswordResetsController < ApplicationController
  before_action :require_no_authentication
  before_action :check_user_params, only: %i[edit update]
  before_action :set_user, only: %i[edit update]

  def create
    @user = User.find_by_email(params[:email])
    if @user.present?
      @user.set_password_reset_token
      PasswordResetMailer.with(user: @user, locale: I18n.locale).reset_email.deliver_later
      flash[:success] ||= []
      flash[:success] << t('controllers.password_resets.instructions_sent')
      redirect_to login_path
    else
      flash[:failure] ||= []
      flash[:failure] << t('controllers.password_resets.email_not_found')
      redirect_to password_reset_path
    end
  end

  def edit; end

  def update
     if user_params[:password].blank? || user_params[:password_confirmation].blank?
       flash[:failure] ||= []
       flash[:failure] << t('controllers.password_resets.fields_blank')
       redirect_to request.fullpath
       return
     elsif user_params[:password].length < 5
       flash[:failure] ||= []
       flash[:failure] << t('controllers.password_resets.too_short')
       redirect_to request.fullpath
       return
     elsif user_params[:password] != user_params[:password_confirmation]
       flash[:failure] ||= []
       flash[:failure] << t('controllers.password_resets.no_match')
       redirect_to request.fullpath
       return
     elsif user_params[:password] == params[:user][:current_password]
       flash[:failure] ||= []
       flash[:failure] << t('controllers.password_resets.same_as_old')
       redirect_to request.fullpath
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
    if params[:user].blank?
      flash[:failure] ||= []
      flash[:failure] << t('controllers.password_resets.failure')
      redirect_to(login_path)
    end
  end

  def set_user
    @user = User.find_by(email: params[:user][:email])
    @user = nil unless @user.authenticate_password_reset_token(params[:user][:password_reset_token])
    unless @user&.password_reset_period_valid?
      flash[:failure] ||= []
      flash[:failure] << t('controllers.password_resets.invalid_token')
      redirect_to login_path
    end
  end
end
