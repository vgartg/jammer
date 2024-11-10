class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :jam, optional: true

  def update_game_average_rating(jam_id = nil)
    Rating.update_average_rating(game, jam_id)
  end
end
