class DashboardController < ApplicationController
  before_action :authenticate_user
  helper_method :find_friend

  def index
    @user = current_user
    @friendships = current_user.friendships.where(status: 'accepted') + current_user.inverse_friendships.where(status: 'accepted')
    @sent_requests = current_user.friendships.where(status: 'pending')
    @received_requests = current_user.inverse_friendships.where(status: 'pending')
    @current_user = current_user
    @games = Game.all.where(status: 1)
    @jams = Jam.all.where(status: 1)
    @sessions = @current_user.sessions.order(created_at: :desc)
    @notifications = current_user.notifications
  end

  private
  def find_friend(friendship)
    if friendship.friend
      friendship.friend.id != current_user.id ? friendship.friend : friendship.user
    end
  end
end