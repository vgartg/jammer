class UsersController < ApplicationController
  before_action :authenticate_user, only: %i[edit_user update_user destroy]

  def new
    return unless current_user

    redirect_to user_path(current_user.id)
  end

  def show
    @user = User.find(params[:id])
    @current_user = current_user
    setup_profile_context

    return render 'private_profile' if @profile_hidden_for_viewer

    @notifications = @current_user.notifications if @current_user
    @friendships = @user.friendships.where(status: 'accepted') + @user.inverse_friendships.where(status: 'accepted')
    @received_requests = @user.inverse_friendships.where(status: 'pending')
  end

  def index
    scope = current_user ? User.where.not(id: current_user.id) : User.all
    if params[:search].present?
      q = "%#{params[:search].downcase}%"
      scope = scope.where('LOWER(name) LIKE ?', q)
    end
    @pagy, @users = pagy(scope, limit: 16)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @token = @user.set_email_confirm_token
      EmailConfirmMailer.with(user: @user, token: @token, locale: I18n.locale).email_confirm.deliver_later
      flash[:success] ||= []
      flash[:success] << t('controllers.users.instructions_sent')
      redirect_to edit_email_confirm_path(user: { email: @user.email })
    else
      flash[:failure] ||= []
      flash[:failure].concat(@user.errors.full_messages)
      flash[:register_params] = params[:user].to_unsafe_h.slice('email', 'name')
      redirect_to register_path
    end
  end

  def destroy
    @user = current_user
    if @user.needs_password? || @user.authenticate(params[:user][:password])
      @user.destroy
      flash[:success] ||= []
      flash[:success] << t('users.destroy.success')
      render json: { success: true }, status: :ok
    else
      flash[:error] = t 'users.destroy.error'
      render json: { success: false, error: t('controllers.users.invalid_password') }, status: :unprocessable_entity
    end
  end

  def edit_user
    @user = current_user
  end

  def update_user
    @user = current_user

    if user_params[:password].present? || user_params[:password_confirmation].present? || params[:user][:current_password].present?
      unless @user.needs_password?
        if params[:user][:current_password].blank?
          flash[:failure] ||= []
          flash[:failure] << t('users.update_user.failure2')
          redirect_to settings_path(anchor: params[:settings_section].presence)
          return
        end

        unless @user.authenticate(params[:user][:current_password])
          flash[:failure] ||= []
          flash[:failure] << t('users.update_user.failure1')
          redirect_to settings_path(anchor: params[:settings_section].presence)
          return
        end
      end

      if user_params[:password].blank? || user_params[:password_confirmation].blank?
        flash[:failure] ||= []
        flash[:failure] << t('users.update_user.failure2')
        redirect_to settings_path
        return
      elsif user_params[:password].length < 5
        flash[:failure] ||= []
        flash[:failure] << t('users.update_user.failure3')
        redirect_to settings_path
        return
      elsif user_params[:password] != user_params[:password_confirmation]
        flash[:failure] ||= []
        flash[:failure] << t('users.update_user.failure4')
        redirect_to settings_path
        return
      elsif !@user.needs_password? && user_params[:password] == params[:user][:current_password]
        flash[:failure] ||= []
        flash[:failure] << t('users.update_user.failure5')
        redirect_to settings_path
        return
      end
    end

    if @user.update(user_params)
      flash[:success] ||= []
      flash[:success] << t('users.update_user.success')
      redirect_to settings_path
    else
      flash[:failure] ||= []
      flash[:failure] << t('users.update_user.failure6')
      redirect_to settings_path
    end
  end

  def update_activity
    if current_user
      current_user.update_columns(last_active_at: Time.current)
      head :ok
    else
      head :unauthorized
    end
  end

  def frontpage
    @user = User.find_by_link_username(params[:username])
    return render_404 unless @user
    @current_user = current_user
    @notifications = current_user&.notifications
    setup_profile_context
    @friendships = @user.friendships.where(status: 'accepted') + @user.inverse_friendships.where(status: 'accepted')
    @received_requests = @user.inverse_friendships.where(status: 'pending')
  end

  private

  def setup_profile_context
    @viewing_own_profile = @current_user&.id == @user.id
    @is_admin = @current_user&.admin?
    @friendship = @current_user&.friendship_with(@user)
    @is_mutual_friend = @friendship&.status == 'accepted'
    @profile_hidden_for_viewer = @user.profile_hidden? && !@viewing_own_profile && !@is_admin && !@is_mutual_friend
    @profile_hidden_admin_view = @user.profile_hidden? && @is_admin && !@viewing_own_profile
  end

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation, :avatar, :background_image,
                  :background_position, :status, :real_name, :location, :birthday, :phone_number, :timezone, :link_username,
                  :visibility, :jams_administrating_visibility, :jams_participating_visibility, :theme, :is_online_today,
                  :notify_friend_requests, :notify_jam_invites, :notify_status_changes, :notify_moderation,
                  :notify_achievements, :notify_team_invites, :notify_admin_messages,
                  :profile_hidden)
  end
end
