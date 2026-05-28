class FriendshipsController < ApplicationController
  before_action :authenticate_user
  helper_method :find_friend

  def index
    @friendships = current_user.friendships.where(status: 'accepted') + current_user.inverse_friendships.where(status: 'accepted')
    @sent_requests = current_user.friendships.where(status: 'pending')
    @received_requests = current_user.inverse_friendships.where(status: 'pending')
    @current_user = current_user
    @notifications = current_user.notifications
  end

  def requests
    @friendships = current_user.friendships.where(status: 'accepted') + current_user.inverse_friendships.where(status: 'accepted')
    @sent_requests = current_user.friendships.where(status: 'pending')
    @received_requests = current_user.inverse_friendships.where(status: 'pending')
    @current_user = current_user
    @notifications = current_user.notifications
  end

  def create
    @user = User.find(params[:user_id])
    existing_friendship = current_user.friendships.find_by(friend: @user) || current_user.inverse_friendships.find_by(user: @user)

    unless existing_friendship
      @friendship = current_user.friendships.build(friend: @user, status: 'pending')
      create_notification(@user, current_user, 'sent_friend_request', @friendship) if @friendship.save
    end
    redirect_to user_profile_path(@user)
  end

  def update
    @friendship = Friendship.where(id: params[:id], friend_id: current_user.id).first
    unless @friendship
      flash[:alert] = t 'friendships.update.alert'
      redirect_to user_profile_path(current_user)
      return
    end

    if @friendship.update(status: 'accepted')
      create_notification(@friendship.user, current_user, 'accepted_friendship', @friendship)
      flash[:notice] = t 'friendships.update.notice'
    else
      flash[:alert] = t 'friendships.update.alert'
    end
    redirect_to user_profile_path(@friendship.user)
  end

  def cancel
    @friendship = find_own_friendship(params[:id])
    return unless @friendship

    @friendship.destroy
    flash[:notice] = t 'friendships.update.notice'
    redirect_to user_profile_path(@friendship.friend)
  end

  def destroy
    @friendship = find_own_friendship(params[:id])
    return unless @friendship

    @friendship.destroy
    flash[:notice] = t 'friendships.update.notice'
    friend = @friendship.friend.id != current_user.id ? @friendship.friend : @friendship.user
    redirect_to user_profile_path(friend)
  end

  private

  def find_own_friendship(id)
    friendship = Friendship.where(id: id)
                           .where('user_id = :uid OR friend_id = :uid', uid: current_user.id)
                           .first
    unless friendship
      flash[:alert] = t 'friendships.update.alert'
      redirect_to user_profile_path(current_user)
      return nil
    end
    friendship
  end

  def find_friend(friendship)
    return unless friendship.friend

    friendship.friend.id != current_user.id ? friendship.friend : friendship.user
  end

  def create_notification(recipient, actor, action, notifiable)
    existing_notifications = Notification.where(recipient: recipient, actor: actor, action: action)

    if existing_notifications.any?
      # Remove old notifications from DB
      existing_notifications.destroy_all
    end

    Notification.create(recipient: recipient, actor: actor, action: action, notifiable: notifiable)
  end
end
