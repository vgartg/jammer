class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def all_users
    @users = User.all
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

  def destroy
    @user = User.find(session[:current_user])
    @games = Game.all
    @games.each do |game|
      if session[:current_user].to_s == game.author_link.split('/')[2]
        game.destroy
      end
    end
    @user.destroy
    redirect_to register_path
  end

  private
  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end