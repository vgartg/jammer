class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :user_mark, presence: true


  after_save :update_game_average_rating

  private

  def update_game_average_rating
    Rating.update_average_rating(game)
  end
end
