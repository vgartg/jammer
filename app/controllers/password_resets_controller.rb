class PasswordResetsController < ApplicationController
  before_action :require_no_authentication
  before_action :check_user_params, only: %i[edit update]
  before_action :set_user, only: %i[edit update]

  def create
    @user = User.find_by_email(params[:email])
    if @user.present?
      @user.set_password_reset_token
      PasswordResetMailer.with(user: @user).reset_email.deliver_later
      flash[:success] ||= []
      flash[:success] << 'Инструкции были отправлены на ваш адрес'
      redirect_to login_path
    else
      flash[:failure] ||= []
      flash[:failure] << 'Не найдена указанная почта'
      redirect_to password_reset_path
    end
  end

  def edit; end

  def update
    if user_params[:password].blank? || user_params[:password_confirmation].blank?
      flash[:failure] = 'All fields must be filled in'
      redirect_to request.fullpath # Пока такой костыль
      return
    elsif user_params[:password].length < 5
      flash[:failure] = 'New password is too short (minimum is 5 characters).'
      redirect_to request.fullpath # Пока такой костыль
      return
    elsif user_params[:password] != user_params[:password_confirmation]
      flash[:failure] = 'New passwords do not match.'
      redirect_to request.fullpath # Пока такой костыль
      return
    elsif user_params[:password] == params[:user][:current_password]
      flash[:failure] = 'New password must be different from the old one.'
      redirect_to request.fullpath # Пока такой костыль
      return
    end

     if @user.update(user_params)
       flash[:success] ||= []
       flash[:success] << "Пароль успешно обновлен!"
       redirect_to login_path
     else
       flash[:failure] ||= []
       flash[:failure] << "Что-то пошло не так!"
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
      flash[:failure] << "Что-то пошло не так!"
      redirect_to(login_path)
    end
  end

  def set_user
    @user = User.find_by(email: params[:user][:email])
    @user = nil unless @user.authenticate_password_reset_token(params[:user][:password_reset_token])
    unless @user&.password_reset_period_valid?
      flash[:failure] ||= []
      flash[:failure] << "Токен недействителен!"
      redirect_to login_path
    end
  end
end
