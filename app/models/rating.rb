class Rating < ApplicationRecord
  belongs_to :game
  belongs_to :jam, optional: true

  validates :game_id, uniqueness: { scope: :jam_id }

  # NOTE: average_rating stores simple review-mark average only.
  # It does not include JamCriterionPick scores (those are in Game#jam_rating).
  # The leaderboard uses this cached value for efficiency.
  def self.update_average_rating(game, jam_id)
    avg = compute_average(game, jam_id)
    game.ratings.find_or_create_by(jam_id: jam_id).update(average_rating: avg)
  rescue ActiveRecord::RecordNotUnique
    game.ratings.find_by!(jam_id: jam_id).update(average_rating: compute_average(game, jam_id))
  end

  private_class_method def self.compute_average(game, jam_id)
    reviews = game.reviews.where(jam_id: jam_id).where.not(user_mark: 0)
    reviews.any? ? reviews.average(:user_mark).to_f.round(1) : 0.0
  end
end
