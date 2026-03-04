class JamCriterion < ApplicationRecord
  self.table_name = "jam_criteria"
  belongs_to :jam
  enum :kind, voted_on: 0, manually_ranked: 1
  scope :active, -> { where(archived: false) }

  validates :title, presence: true
  validates :title, uniqueness: { scope: :jam_id }
end