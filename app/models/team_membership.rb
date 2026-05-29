class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user

  ROLES = %w[leader member].freeze
  STATUSES = %w[pending accepted declined].freeze

  validates :role, inclusion: { in: ROLES }
  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :team_id }

  scope :accepted, -> { where(status: 'accepted') }
  scope :pending, -> { where(status: 'pending') }
  scope :invited, -> { where(leader_invited: true, status: 'pending') }
  scope :requested, -> { where(leader_invited: false, status: 'pending') }
end
