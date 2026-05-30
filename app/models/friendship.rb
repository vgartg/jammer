class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :status, presence: true
  after_initialize :set_default_status, if: :new_record?
  after_save :check_friendship_achievements, if: -> { saved_change_to_status? && status == 'accepted' }
  before_destroy :cleanup_notifications

  private

  def check_friendship_achievements
    AchievementService.check_and_award(user)
    AchievementService.check_and_award(friend)
  end

  def cleanup_notifications
    Notification.where(notifiable: self).destroy_all
  end

  def set_default_status
    self.status ||= 'pending'
  end
end
