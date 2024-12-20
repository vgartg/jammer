class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :status, presence: true
  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
