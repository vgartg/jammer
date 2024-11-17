class Rating < ApplicationRecord
  def self.update_average_rating(game, jam_id)
    if jam_id
      reviews = game.reviews.where(game_id: game.id, jam_id: jam_id).where.not(user_mark: 0)
      average_rating = reviews.any? ? reviews.average(:user_mark).to_f.round(1) : 0.0
      game.ratings.find_or_create_by(jam_id: jam_id).update(average_rating: average_rating)
    else
      reviews = game.reviews.where(game_id: game.id, jam_id: nil).where.not(user_mark: 0)
      overall_average_rating = reviews.any? ? reviews.average(:user_mark).to_f.round(1) : 0.0
      game.ratings.find_or_create_by(jam_id: nil).update(average_rating: overall_average_rating)
    end
  end

end
