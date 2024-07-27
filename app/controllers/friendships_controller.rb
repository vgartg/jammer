class FriendshipsController < ApplicationController
  before_action :authenticate_user
  helper_method :find_friend
  def index
    @friendships = current_user.friendships.where(status: 'accepted') + current_user.inverse_friendships.where(status: 'accepted')
    @sent_requests = current_user.friendships.where(status: 'pending')
    @received_requests = current_user.inverse_friendships.where(status: 'pending')
    @current_user = current_user
  end
  def create
    # Проверяем, существует ли уже запрос дружбы между текущим пользователем и выбранным пользователем
    existing_friendship = current_user.friendships.find_by(friend: @user) ||
      current_user.inverse_friendships.find_by(user: @user)

    unless existing_friendship
      @user = User.find(params[:user_id])
      @friendship = current_user.friendships.build(friend: @user, status: 'pending')
      @friendship.save
      redirect_to user_profile_path(@user)
    end

  end

  def update
    @friendship = Friendship.find(params[:id])

    if @friendship.update(status: 'accepted')
      flash[:notice] = "Запрос дружбы принят."
    else
      flash[:alert] = "Не удалось принять запрос дружбы."
    end
    redirect_to user_profile_path(@friendship.user)
  end

  def cancel
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    flash[:notice] = "Запрос на дружбу отменен."
    redirect_to user_profile_path(@friendship.friend)
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    flash[:notice] = "Дружба отменена."
    @friendship.friend.id != current_user.id ? friend = @friendship.friend : friend = @friendship.user
    redirect_to user_profile_path(friend)
  end

  private
  def find_friend(friendship)
    friendship.friend.id != current_user.id ? friendship.friend : friendship.user
  end
end