class JamCriterionPick < ApplicationRecord
  belongs_to :jam
  belongs_to :jam_criterion
  belongs_to :voter, class_name: "User"
  belongs_to :game

  validates :channel, inclusion: { in: %w[jury audience] }
end