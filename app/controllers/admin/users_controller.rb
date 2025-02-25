module Admin
  class UsersController < ApplicationController
    before_action :admin?
    before_action :set_user!, only: %i[edit update destroy]
    helper_method :find_user_friend

    def index
      users = search_users(User.all)
      users = sort_users(users)
      @pagy, @users = pagy(users, limit: 10)
    end

    def create
      @user = User.new(user_params)

      if @user.save
        flash[:success] = 'Пользователь успешно создан'

        create_administration_record(current_user, @user, {}, 'create')

        redirect_to admin_users_path
      else
        flash[:failure] = @user.errors.full_messages
        redirect_to new_admin_user_path
      end
    end

    def new
      @user = User.new
    end

    def edit
      @user = User.find(params[:id])

      return unless @user

      @user_sessions = @user.sessions.order(created_at: :desc)
      @user_notifications = @user.notifications
      @user_friendships = @user.friendships.where(status: 'accepted') + @user.inverse_friendships.where(status: 'accepted')
      @user_sent_requests = @user.friendships.where(status: 'pending')
      @user_received_requests = @user.inverse_friendships.where(status: 'pending')
    end

    def update
      if @user.update(user_params)
        flash[:success] = 'Пользователь успешно обновлен'

        changes = @user.previous_changes.except('updated_at')

        if changes.any?
          create_administration_record(current_user, @user, changes, 'edit')
        end
      else
        flash[:failure] = @user.errors.full_messages
      end
      redirect_to request.fullpath
    end

    def destroy
      create_administration_record(current_user, @user, {}, 'delete') if @user.destroy
      flash[:success] = 'Пользователь успешно удален'
      redirect_to admin_users_path
    end

    def freeze
      user = User.find(params[:id])
      duration = params[:duration]

      # Определяем дату разморозки
      unfreeze_at = case duration
                    when "1.hour" then 1.hour.from_now
                    when "6.hours" then 6.hours.from_now
                    when "12.hours" then 12.hours.from_now
                    when "1.day" then 1.day.from_now
                    when "3.days" then 3.days.from_now
                    when "7.days" then 7.days.from_now
                    when "1.month" then 1.month.from_now
                    when "6.months" then 6.months.from_now
                    when "1.year" then 1.year.from_now
                    when "forever" then nil
                    else
                      return render json: { error: "Некорректный срок" }, status: :unprocessable_entity
                    end

      user.update!(
        is_frozen: true,
        frozen_at: Time.current,
        unfreeze_at: unfreeze_at,
        frozen_reason: params[:reason]
      )
    end

    def unfreeze
      user = User.find(params[:id])
      user.update!(
        is_frozen: false,
        frozen_reason: nil,
        frozen_at: nil,
        unfreeze_at: nil
      )
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
          users.where(id: query.to_i)
        else
          role_query = User.roles[query]
          users.where('name ILIKE :query OR email ILIKE :query OR created_at::TEXT ILIKE :query OR role = :role_query',
                      query: "%#{query}%", role_query: role_query)
        end
      else
        users
      end
    end

    def find_user_friend(user_friendship, user)
      return unless user_friendship.friend

      user_friendship.friend.id != user.id ? user_friendship.friend : user_friendship.user
    end

    def user_params
      params.require(:user).permit(
        :email, :name, :email_confirmed, :password, :password_confirmation, :role, :avatar, :background_image,
        :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
        :visibility, :jams_visibility, :theme, :is_frozen, :frozen_at, :unfreeze_at, :frozen_reason
      ).merge(admin_edit: true)
    end
  end
end
