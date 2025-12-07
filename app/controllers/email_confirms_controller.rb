class EmailConfirmsController < ApplicationController
  before_action :check_params, only: [:update]
  before_action :set_user_by_email, only: [:edit]
  before_action :set_user, only: [:update]

  def edit; end

  def update
    if @user.update(email_confirmed: true)
      session[:current_user] = @user.id
      unless Session.all.where(ip_address: request.remote_ip, browser: browser).exists?
        Session.create_session(@user.id, session[:session_id], request.remote_ip, browser)
      end
      remember(@user) if params[:remember_me] == '1'
      flash[:success] ||= []
      flash[:success] << 'Email Confirmed successfully.'
      redirect_to dashboard_path
    else
      flash[:failure] ||= []
      flash[:failure] << 'Something went wrong.'
      redirect_to register_path
    end
  end

  private

  def check_params
    if params[:user][:code].blank?
      flash[:failure] ||= []
      flash[:failure] << "Код не может быть пуст"
      redirect_to request.fullpath
    end
  end

  def set_user_by_email
    @user = User.find_by(email: params[:user][:email])
    unless @user
      flash[:failure] ||= []
      flash[:failure] << "Пользователь не найден."
      redirect_to register_path
    end
  end

  def set_user
    @user = User.find_by(email: params[:user][:email])
    @user = nil unless @user.authenticate_email_confirm_token(params[:user][:code])
    unless @user&.email_confirm_period_valid?
      flash[:failure] ||= []
      flash[:failure] << "Код недействителен!"
      redirect_to request.fullpath
    end
  end
end
