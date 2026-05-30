class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :jam, optional: true

  enum :vote_type, audience: 0, jury: 1

  validates :criterion, presence: true, if: -> { jam_id.present? }
  validates :user_mark, inclusion: { in: 0.0..5.0 }
  validates :comment, length: { maximum: 1000 }, allow_nil: true

  after_save :recalculate_rating
  after_save :check_achievements
  after_destroy :recalculate_rating
  after_destroy :check_achievements_after_destroy

  private

  def recalculate_rating
    Rating.update_average_rating(game, jam_id)
  end

  def check_achievements
    AchievementService.check_and_award(user)
    AchievementService.check_and_award(game.author) if game.author != user
  end

  def check_achievements_after_destroy
    AchievementService.check_and_award(user)
  end
end