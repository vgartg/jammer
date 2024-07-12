class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:current_user] = @user.id
      redirect_to dashboard_path
    else
      flash[:errors] = @user.errors.full_messages
      render :new, status: :see_other
    end
  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation)
  end
end