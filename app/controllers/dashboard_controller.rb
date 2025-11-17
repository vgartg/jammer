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

    @reviews_in_jams = Review.where(user: @user).where.not(jam_id: nil).includes(:game, :jam)
    @reviews_no_jam = Review.where(user: @user).where(jam_id: nil).includes(:game, :jam)

    @average_rating_no_jam = @user.games.joins(:ratings)
                                  .where(ratings: { jam_id: nil })
                                  .where.not(ratings: { average_rating: 0 })
                                  .average(:average_rating)

    @average_rating_in_jams = @user.games.joins(:ratings)
                                   .where.not(ratings: { jam_id: nil })
                                   .where.not(ratings: { average_rating: 0 })
                                   .average(:average_rating)
  end

  private

  def find_friend(friendship)
    return unless friendship.friend

    friendship.friend.id != current_user.id ? friendship.friend : friendship.user
  end
end
