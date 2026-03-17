class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :jam, optional: true

  enum :vote_type, audience: 0, jury: 1

  validates :criterion, presence: true
  validates :user_mark, inclusion: { in: 0.0..5.0 }
  validates :comment, length: { maximum: 1000 }, allow_nil: true

  after_save :recalculate_rating
  after_destroy :recalculate_rating

  private

  def recalculate_rating
    Rating.update_average_rating(game, jam_id)
  end
end