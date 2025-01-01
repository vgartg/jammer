class SearchController < ApplicationController
  helper_method :find_friend
  def index
    query = params[:search].to_s.strip
    @games = Game.where('name ILIKE :query OR description ILIKE :query', query: "%#{query}%")
    @jams = Jam.where('name ILIKE :query OR description ILIKE :query', query: "%#{query}%")
    @friendships = Friendship.where(status: 'accepted')
                             .where('(user_id = :current_user_id OR friend_id = :current_user_id)', current_user_id: current_user.id)
                             .joins('LEFT JOIN users ON users.id = friendships.user_id OR users.id = friendships.friend_id')
                             .where('users.name ILIKE :query', query: "%#{query}%")



    @results = {
      games: @games,
      jams: @jams,
      friends: @friendships
    }
  end

  private
  def find_friend(friendship)
    if friendship.friend
      friendship.friend.id != current_user.id ? friendship.friend : friendship.user
    end
  end
end
