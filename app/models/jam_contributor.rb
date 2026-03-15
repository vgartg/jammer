class JamContributor < ApplicationRecord
  belongs_to :jam
  belongs_to :user

  STATUSES = %w[pending accepted].freeze
  validates :status, inclusion: { in: STATUSES }

  after_initialize :set_defaults, if: :new_record?

  scope :accepted, -> { where(status: "accepted") }
  scope :pending,  -> { where(status: "pending") }

  private

  def set_defaults
    self.status ||= "pending"
  end
end