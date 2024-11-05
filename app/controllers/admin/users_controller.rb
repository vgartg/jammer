module Admin
  class UsersController < ApplicationController
    before_action :admin?
    before_action :set_user!, only: %i[edit update destroy]

    def index
      users = search_users(User.all)
      users = sort_users(users)
      @pagy, @users = pagy(users, limit: 15)
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

    def sort_users(users)
      sortable_columns = %w[id name email role created_at]
      sort_by = sortable_columns.include?(params[:sort_by]) ? params[:sort_by] : 'id'
      direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      users.order("#{sort_by} #{direction}")
    end

    def search_users(users)
      if params[:query].present?
        query = params[:query].strip.downcase

        if query.to_i.to_s == query
          users = users.where(id: query.to_i)
        else
          role_query = User.roles[query]
          users = users.where("name ILIKE :query OR email ILIKE :query OR created_at::TEXT ILIKE :query OR role = :role_query",
                              query: "%#{query}%", role_query: role_query)
        end
      else
        users
      end
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