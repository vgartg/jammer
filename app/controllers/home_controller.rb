class HomeController < ApplicationController
  def index
    @user = current_user
    @current_user = current_user
    @stats = {
      jams: Jam.count,
      games: Game.where(status: 1).count,
      users: User.count
    }
    @recent_jams = Jam.where(status: 1).order(created_at: :desc).limit(6)
  end
end
