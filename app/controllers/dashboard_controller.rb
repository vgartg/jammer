class DashboardController < ApplicationController
  helper_method :find_friend

  def index
    @announcements = Announcement.published.limit(5).to_a
    return unless current_user

    @user = current_user
    @current_user = current_user
    @friendships = current_user.friendships.where(status: 'accepted') + current_user.inverse_friendships.where(status: 'accepted')
    @sent_requests = current_user.friendships.where(status: 'pending')
    @received_requests = current_user.inverse_friendships.where(status: 'pending')
    @notifications = current_user.notifications

    authored_ids = @user.jams.where(status: 1).pluck(:id)
    admin_ids = @user.jam_contributors.where(status: 'accepted', admin: true).pluck(:jam_id)
    @user_jams = Jam.where(id: (authored_ids + admin_ids).uniq).order(start_date: :desc)

    @reviews_in_jams = Review.where(user: @user).where.not(jam_id: nil).includes(:game, :jam)
    @reviews_no_jam = Review.where(user: @user).where(jam_id: nil).includes(:game)

    @average_rating_no_jam = @user.games.joins(:ratings)
                                  .where(ratings: { jam_id: nil })
                                  .where.not(ratings: { average_rating: 0 })
                                  .average(:average_rating)

    @average_rating_in_jams = @user.games.joins(:ratings)
                                   .where.not(ratings: { jam_id: nil })
                                   .where.not(ratings: { average_rating: 0 })
                                   .average(:average_rating)

    @games_count = @user.games.count
  end

  private

  def find_friend(friendship)
    return unless friendship.friend

    friendship.friend.id != current_user.id ? friendship.friend : friendship.user
  end
end
