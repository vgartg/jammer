class SearchController < ApplicationController
  def index
    query = params[:search].to_s.strip
    @games = Game.where('name ILIKE :query OR description ILIKE :query', query: "%#{query}%")
    @jams = Jam.where('name ILIKE :query OR description ILIKE :query', query: "%#{query}%")

    @results = {
      games: @games,
      jams: @jams,
    }
  end
end
