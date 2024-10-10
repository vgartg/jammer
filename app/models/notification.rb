class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User", foreign_key: 'recipient_id'
  belongs_to :actor, class_name: "User", foreign_key: 'actor_id'
  belongs_to :notifiable, polymorphic: true

  validates :recipient_id, :actor_id, :action, :notifiable_id, :notifiable_type, presence: true

  scope :unread, -> { where(read: false) }
end