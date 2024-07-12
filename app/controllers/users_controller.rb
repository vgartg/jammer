class UsersController < ApplicationController
  def new
    @user = User.new
    @errors = {}
  end

  def create
    @user = User.new(user_params)
    @errors = validate(@user)
    if @errors.empty? && @user.save
      session[:current_user] = @user.id
      redirect_to dashboard_path
    else
      puts @errors
      render :new
    end
  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation)
  end
end