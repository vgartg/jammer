class Team < ApplicationRecord
  belongs_to :leader, foreign_key: 'leader_id', class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :jam_submissions, foreign_key: 'team_id'
  has_many :accepted_memberships, -> { where(status: 'accepted') }, class_name: 'TeamMembership'
  has_many :members, through: :team_memberships, source: :user
  has_one_attached :avatar

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }
  validates :open_membership, inclusion: { in: [true, false] }

  after_create :create_leader_membership
  after_create :check_leader_achievements

  def accepted_members
    team_memberships.where(status: 'accepted').includes(:user).map(&:user)
  end

  def member?(user)
    return false unless user

    team_memberships.where(user: user, status: 'accepted').exists? || leader == user
  end

  def pending_membership_for(user)
    team_memberships.find_by(user: user, status: 'pending')
  end

  private

  def create_leader_membership
    team_memberships.create!(user: leader, role: 'leader', status: 'accepted')
  end

  def check_leader_achievements
    AchievementService.check_and_award(leader)
  end
end
