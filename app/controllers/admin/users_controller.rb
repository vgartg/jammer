module Admin
  class UsersController < ApplicationController
    before_action :admin?
    before_action :set_user!, only: %i[edit update destroy]

    def index
      @pagy, @users = pagy((User.all), limit: 15)
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
      else
        flash[:failure] = @user.errors.full_messages
      end
      redirect_to request.fullpath
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
        :email, :name, :email_confirmed, :password, :password_confirmation, :role, :avatar, :background_image,
        :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
        :visibility, :jams_visibility, :theme
      ).merge(admin_edit: true)
    end
  end
end