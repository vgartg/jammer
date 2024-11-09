class Rating < ApplicationRecord
  belongs_to :game

  # Этот метод обновляет средний рейтинг игры на основе всех оценок в reviews
  def self.update_average_rating(game)
    average_rating = game.reviews.average(:user_mark).to_f.round(1)
    game.rating.update(average_rating: average_rating) if game.rating
  end
end
