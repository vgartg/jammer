module Admin
  class UsersController < ApplicationController
    before_action :admin?
    before_action :set_user!, only: %i[edit update destroy]

    def index
      @users = User.all

      # pagination. will be later...
      # @pagy, @users = pagy((User.all), items: 20)
    end

    def create
      # will release later...
      redirect_to admin_users_path
    end

    def edit
    end

    def update
      if @user.update(user_params)
        flash[:success] = 'Готово'
        redirect_to admin_users_path
      else
        flash[:failure] = @user.errors.full_messages
        redirect_to request.fullpath
      end
    end

    def destroy
      @user.destroy
      flash[:success] = 'Готово'
      redirect_to admin_users_path
    end

    private

    def set_user!
      @user = User.find params[:id]
    end

    def user_params
      params.require(:user).permit(
        :email, :name, :email_confirmed, :password, :password_confirmation, :role
      ).merge(admin_edit: true)
    end
  end
end