class Rating < ApplicationRecord
  belongs_to :game
  belongs_to :jam, optional: true

  validates :game_id, uniqueness: { scope: :jam_id }

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
  rescue ActiveRecord::RecordNotUnique
    rating = game.ratings.find_by!(jam_id: jam_id)
    avg = jam_id ? game.reviews.where(jam_id: jam_id).where.not(user_mark: 0).average(:user_mark).to_f.round(1) : 0.0
    rating.update(average_rating: avg)
  end
end
