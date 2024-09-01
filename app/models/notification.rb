class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  validates :recipient_id, :actor_id, :action, :notifiable_id, :notifiable_type, presence: true

  scope :unread, -> { where(read: false) }
end