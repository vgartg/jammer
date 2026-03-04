class JamCriterion < ApplicationRecord
  self.table_name = "jam_criteria"
  belongs_to :jam
  enum :kind, voted_on: 0, manually_ranked: 1

  validates :title, presence: true
end