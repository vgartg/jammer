class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to user_path(current_user.id)
    end
  end

  def create
    user = User.find_by_email(auth_params[:email])
    if user.present? && user.authenticate(auth_params[:password])
      session[:current_user] = user.id
      if params[:remember_me] == "1"
        remember(user)
      end
      user.update(last_seen_at: Time.zone.now)
      redirect_to dashboard_path
    else
      flash[:errors] = ["Invalid email or password"]
      render :new, status: :see_other
    end
  end

  def destroy
    forget(current_user)
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

  private

  def auth_params
    params.permit(:email, :password, :remember_me)
  end
end