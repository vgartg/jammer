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
      user.update(last_seen_at: Time.zone.now)
      redirect_to dashboard_path
    else
      flash[:errors] = ["Invalid email or password"]
      render :new, status: :see_other
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