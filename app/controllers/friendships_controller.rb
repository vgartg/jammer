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
    @default_tab = 'received_requests'
    render :index
  end

  def create
    @user = User.find(params[:user_id])
    existing_friendship = current_user.friendships.find_by(friend: @user) || current_user.inverse_friendships.find_by(user: @user)

    unless existing_friendship
      @friendship = current_user.friendships.build(friend: @user, status: 'pending')
      User.create_notification(@user, current_user, 'sent_friend_request', @friendship) if @friendship.save
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

    sender = @friendship.user
    if @friendship.update(status: 'accepted')
      User.create_notification(sender, current_user, 'accepted_friendship', @friendship) if sender
      flash[:notice] = t 'friendships.update.notice'
    else
      flash[:alert] = t 'friendships.update.alert'
    end
    redirect_to sender ? user_profile_path(sender) : news_path
  end

  def cancel
    @friendship = find_own_friendship(params[:id])
    return unless @friendship

    friend = @friendship.friend
    user   = @friendship.user
    @friendship.destroy
    flash[:notice] = t 'friendships.update.notice'
    other = (friend && friend.id != current_user.id) ? friend : user
    redirect_to other ? user_profile_path(other) : news_path
  end

  def destroy
    @friendship = find_own_friendship(params[:id])
    return unless @friendship

    friend = @friendship.friend
    user   = @friendship.user
    @friendship.destroy
    flash[:notice] = t 'friendships.update.notice'
    other = (friend && friend.id != current_user.id) ? friend : user
    redirect_to other ? user_profile_path(other) : news_path
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


end
