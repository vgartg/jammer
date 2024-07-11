class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by_email(auth_params[:email])
    if user.present? && user.authenticate(auth_params[:password])
      session[:current_user] = user.id
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end

  def destroy
    session[:current_user] = nil
    redirect_to root_path
  end


  private
  def auth_params
    params.permit(:email, :password)
  end
end