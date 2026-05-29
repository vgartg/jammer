class UserAchievement < ApplicationRecord
  belongs_to :user

  validates :achievement_key, presence: true
  validates :achievement_key, uniqueness: { scope: :user_id }
  validates :earned_at, presence: true
end
